import Foundation
import SwiftUI

extension URLRequest {
    static let initial: URLRequest = {
        var res = URLRequest(url: .temporaryDirectory)
        res.url = nil
        return res
    }()
}

final class RequestSourceOfTruth: Sendable {
    init(baseUrl: URL? = nil, pathComponents: URLComponents = URLComponents(), request: URLRequest = .initial) {
        self.baseUrl = baseUrl
        self.request = request
        self.pathComponents = pathComponents
    }

    let baseUrl: URL?
    nonisolated(unsafe) var pathComponents: URLComponents
    nonisolated(unsafe) var request: URLRequest
}

extension RequestSourceOfTruth {
    var state: RequestState {
        RequestState(
            baseUrl: baseUrl,
            request: Binding { self.request } set: { self.request = $0 },
            pathComponents: Binding { self.pathComponents } set: { self.pathComponents = $0 }
        )
    }
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

struct Post: BuilderNode {
    func modify(state: RequestState) {
        state.request.httpMethod = "POST"
    }
}

struct Get: BuilderNode {
    func modify(state: RequestState) {
        state.request.httpMethod = "GET"
    }
}

struct Delete: BuilderNode {
    func modify(state: RequestState) {
        state.request.httpMethod = "DELETE"
    }
}

struct Put: BuilderNode {
    func modify(state: RequestState) {
        state.request.httpMethod = "PUT"
    }
}

struct Head: BuilderNode {
    func modify(state: RequestState) {
        state.request.httpMethod = "HEAD"
    }
}

struct Patch: BuilderNode {
    func modify(state: RequestState) {
        state.request.httpMethod = "PATCH"
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
    static func buildBlock(_ nodes: BuilderNode...) -> [BuilderNode] {
        nodes
    }
}
