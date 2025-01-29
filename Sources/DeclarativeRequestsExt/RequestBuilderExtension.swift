@_exported import DeclarativeRequests
import Foundation

public extension RequestBuilder {
    static func buildExpression(_ url: URL?) -> RootNode {
        RootNode(BaseURL(url).transformer)
    }

    static func buildExpression(_ callback: @escaping StateTransformer) -> RootNode {
        RootNode(callback)
    }

    static func buildExpression(_ data: Data?) -> RootNode {
        RootNode { result in
            result.request.httpBody = data
        }
    }

    static func buildExpression(_ path: String) -> RootNode {
        RootNode(Endpoint(path).transformer)
    }

    static func buildExpression(_ query: URLQueryItem) -> RootNode {
        RootNode(Query([query.name: query.value]).transformer)
    }
}
