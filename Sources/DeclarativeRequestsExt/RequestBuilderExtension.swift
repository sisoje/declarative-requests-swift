@_exported import DeclarativeRequests
import Foundation

public extension RequestBuilder {
    static func buildExpression(_ url: URL?) -> RequestBlock {
        RequestBlock(BaseURL(url).transformer)
    }

    static func buildExpression(_ callback: @escaping StateTransformer) -> RequestBlock {
        RequestBlock(callback)
    }

    static func buildExpression(_ data: Data?) -> RequestBlock {
        RequestBlock { result in
            result.request.httpBody = data
        }
    }

    static func buildExpression(_ path: String) -> RequestBlock {
        RequestBlock(Endpoint(path).transformer)
    }

    static func buildExpression(_ query: URLQueryItem) -> RequestBlock {
        RequestBlock(Query([query.name: query.value]).transformer)
    }
}
