import Foundation
import SwiftUI

extension URLRequest {
    static let initial: URLRequest = {
        var res = URLRequest(url: .temporaryDirectory)
        res.url = nil
        return res
    }()
}

struct RequestState {
    var baseUrl: URL?
    @Binding var request: URLRequest
    @Binding var pathComponents: URLComponents
}

extension RequestState {
    func runBuilder(_ builder: BuilderNode) throws {
        try builder.modify(state: self)
    }
}

protocol BuilderNode {
    func modify(state: RequestState) throws
}

struct HttpMethod: BuilderNode {
    enum Methods: String {
        case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH
    }
    
    let method: Methods
    
    func modify(state: RequestState) {
        state.request.httpMethod = method.rawValue
    }
}

struct JsonBody<T: Encodable>: BuilderNode {
    let value: T
    var encoder = JSONEncoder()
    func modify(state: RequestState) throws {
        state.request.httpBody = try encoder.encode(value)
    }
}

struct AddQueryParams: BuilderNode {
    let params: [String: String?]
    func modify(state: RequestState) {
        let newItems = params.map(URLQueryItem.init)
        let oldItems = state.pathComponents.queryItems ?? []
        state.pathComponents.queryItems = oldItems + newItems
    }
}

struct CreateURL: BuilderNode {
    func modify(state: RequestState) {
        state.request.url = state.pathComponents.url(relativeTo: state.baseUrl)
    }
}

struct Endpoint: BuilderNode {
    let path: String
    func modify(state: RequestState) {
        state.pathComponents.path = path
    }
}

struct RequestBuilderGroup: BuilderNode {
    let nodes: [BuilderNode]

    init(@RequestBuilder _ builder: () -> [BuilderNode]) {
        self.nodes = builder()
    }

    func modify(state: RequestState) throws {
        try nodes.forEach { try $0.modify(state: state) }
    }
}

@resultBuilder
struct RequestBuilder {
    static func buildBlock() -> [BuilderNode] {
        []
    }
    
    static func buildBlock(_ components: BuilderNode...) -> [BuilderNode] {
        components
    }
    
    static func buildExpression(_ expression: BuilderNode) -> [BuilderNode] {
        [expression]
    }
    
    static func buildEither(first component: [BuilderNode]) -> [BuilderNode] {
        component
    }
    
    static func buildBlock(_ components: [any BuilderNode]...) -> [any BuilderNode] {
        components.flatMap { $0 }
    }
    
    static func buildEither(second component: [BuilderNode]) -> [BuilderNode] {
        component
    }
    
    static func buildOptional(_ component: [BuilderNode]?) -> [BuilderNode] {
        component ?? []
    }
    
    static func buildArray(_ components: [[BuilderNode]]) -> [BuilderNode] {
        components.flatMap { $0 }
    }
}
