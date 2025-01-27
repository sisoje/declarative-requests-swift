import Foundation
import SwiftUI

struct RequestState {
    @Binding var request: URLRequest
    @Binding var pathComponents: URLComponents
}

extension RequestState {
    func runBuilder(@RequestBuilder _ builder: () -> [BuilderNode]) throws {
        try builder().forEach { try $0.modify(state: self) }
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

struct BaseURL: BuilderNode {
    let url: URL
    func modify(state: RequestState) {
        state.request.url = state.pathComponents.url(relativeTo: url)
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

    init() {
        nodes = []
    }

    init(@RequestBuilder builder: () -> [BuilderNode]) {
        nodes = builder()
    }

    func modify(state: RequestState) throws {
        try nodes.forEach { try $0.modify(state: state) }
    }
}

@resultBuilder
struct RequestBuilder {
    /// Required to build empty block
    static func buildBlock() -> [BuilderNode] {
        []
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: BuilderNode...) -> [BuilderNode] {
        components
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results
    static func buildExpression(_ expression: BuilderNode) -> [BuilderNode] {
        [expression]
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: [any BuilderNode]...) -> [any BuilderNode] {
        components.flatMap { $0 }
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: [BuilderNode]) -> [BuilderNode] {
        component
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: [BuilderNode]) -> [BuilderNode] {
        component
    }

    /// Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: [BuilderNode]?) -> [BuilderNode] {
        component ?? []
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [[BuilderNode]]) -> [BuilderNode] {
        components.flatMap { $0 }
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: [any BuilderNode]) -> [any BuilderNode] {
        component
    }

    /// Builds a partial result component from the first component
    static func buildPartialBlock(first: [any BuilderNode]) -> [any BuilderNode] {
        first
    }

    /// Builds a partial result component by combining an accumulated component and a new component
    static func buildPartialBlock(accumulated: [any BuilderNode], next: [any BuilderNode]) -> [any BuilderNode] {
        accumulated + next
    }

    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result
    static func buildFinalResult(_ component: [any BuilderNode]) -> [BuilderNode] {
        component
    }
}
