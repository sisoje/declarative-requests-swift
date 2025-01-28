import Foundation

struct CustomTransformer: RequestBuilderNode {
    let transformer: RequestTransformer
}

enum HTTPMethod: String, RequestBuilderNode {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH
    func modify(state: inout RequestBuilderState) {
        state.request.httpMethod = rawValue
    }

    static func custom(_ method: String) -> RequestBuilderNode {
        CustomTransformer {
            $0.request.httpMethod = method
        }
    }
}

struct JSONBody<T: Encodable>: RequestBuilderNode {
    let value: T
    var encoder = JSONEncoder()
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = try encoder.encode(value)
    }
}

struct PostData: RequestBuilderNode {
    let data: Data?
    
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = data
    }
}

struct QueryParams: RequestBuilderNode {
    let params: [String: String?]
    func modify(state: inout RequestBuilderState) {
        let newItems = params.map(URLQueryItem.init)
        let oldItems = state.pathComponents.queryItems ?? []
        state.pathComponents.queryItems = oldItems + newItems
    }
}

struct BaseURL: RequestBuilderNode {
    let url: URL?
    func modify(state: inout RequestBuilderState) {
        state.baseURL = url
    }
}

struct Endpoint: RequestBuilderNode {
    let path: String
    func modify(state: inout RequestBuilderState) {
        state.pathComponents.path = path
    }
}

struct RequestBuilderGroup: RequestBuilderNode {
    @RequestBuilder let builder: () -> RequestTransformer
    var transformer: RequestTransformer {
        builder()
    }
}
