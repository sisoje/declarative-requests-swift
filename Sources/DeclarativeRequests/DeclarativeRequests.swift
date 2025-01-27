import Foundation
import SwiftUI

typealias RequestTransformer = (inout RequestBuilderState) throws -> Void

enum Transformer {
    static var nop: RequestTransformer { { _ in } }
    static func oneNode(_ node: BuilderNode) -> RequestTransformer {
        { state in
            try node.modify(state: &state)
        }
    }

    static func multiNode(_ nodes: [BuilderNode]) -> RequestTransformer {
        { state in
            for node in nodes {
                try node.modify(state: &state)
            }
        }
    }

    static func merge(_ transformers: [RequestTransformer]) -> RequestTransformer {
        { state in
            for transformer in transformers {
                try transformer(&state)
            }
        }
    }

    static func merge(_ transformers: RequestTransformer...) -> RequestTransformer {
        { state in
            for transformer in transformers {
                try transformer(&state)
            }
        }
    }
}

protocol BuilderNode {
    func modify(state: inout RequestBuilderState) throws
}

enum HttpMethod: String, BuilderNode {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH
    func modify(state: inout RequestBuilderState) {
        state.request.httpMethod = rawValue
    }
    static func custom(_ method: String) -> BuilderNode {
        RequestBuilderGroup(builder: {
            return { state in state.request.httpMethod = method }
        })
    }
}

struct JSONBody<T: Encodable>: BuilderNode {
    let value: T
    var encoder = JSONEncoder()
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = try encoder.encode(value)
    }
}

struct QueryParams: BuilderNode {
    let params: [String: String?]
    func modify(state: inout RequestBuilderState) {
        let newItems = params.map(URLQueryItem.init)
        let oldItems = state.pathComponents.queryItems ?? []
        state.pathComponents.queryItems = oldItems + newItems
    }
}

struct BaseURL: BuilderNode {
    let url: URL
    func modify(state: inout RequestBuilderState) {
        state.request.url = state.pathComponents.url(relativeTo: url)
    }
}

struct Endpoint: BuilderNode {
    let path: String
    func modify(state: inout RequestBuilderState) {
        state.pathComponents.path = path
    }
}

struct RequestBuilderGroup: BuilderNode {
    @RequestBuilder let builder: () -> RequestTransformer
    func modify(state: inout RequestBuilderState) throws {
        try builder()(&state)
    }
}

@resultBuilder
struct RequestBuilder {
    static func buildBlock() -> RequestTransformer {
        Transformer.nop
    }

    static func buildBlock(_ components: BuilderNode...) -> RequestTransformer {
        Transformer.multiNode(components)
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: RequestTransformer...) -> RequestTransformer {
        Transformer.merge(components)
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results
    static func buildExpression(_ expression: BuilderNode) -> RequestTransformer {
        Transformer.oneNode(expression)
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: [any BuilderNode]...) -> RequestTransformer {
        Transformer.multiNode(components.flatMap { $0 })
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }

    // Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: RequestTransformer?) -> RequestTransformer {
        component ?? Transformer.nop
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [RequestTransformer]) -> RequestTransformer {
        Transformer.merge(components)
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }

    /// Builds a partial result component from the first component
    static func buildPartialBlock(first: @escaping RequestTransformer) -> RequestTransformer {
        first
    }

    /// Builds a partial result component by combining an accumulated component and a new component
    static func buildPartialBlock(accumulated: @escaping RequestTransformer, next: @escaping RequestTransformer) -> RequestTransformer {
        Transformer.merge(accumulated, next)
    }

    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result
    static func buildFinalResult(_ component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }
}
