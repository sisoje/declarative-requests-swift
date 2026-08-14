import Foundation

@_documentation(visibility: internal)
public typealias RequestStateTransformClosure = (RequestState) throws -> Void

public protocol RequestBuildable {
    associatedtype Body: RequestBuildable
    @RequestBuilder var body: Body { get }
}

extension RequestBuildable {
    var transform: RequestStateTransformClosure {
        if let leaf = self as? RequestBlock {
            leaf.transform
        } else {
            body.transform
        }
    }
}

public extension RequestBuildable {
    /// Materializes. Pass a premade request to apply the blocks on top of it instead of a blank one.
    func request(initialRequest: URLRequest? = nil) throws -> URLRequest {
        let state = RequestState(request: initialRequest)
        try transform(state)
        return state.request
    }

    /// Applies only after the path and query are finished — chain it right after the blocks that write them.
    func base(_ url: URL) -> some RequestBuildable {
        RequestBlock {
            self
            BaseURL(url)
        }
    }

    func useEncoder(_ encoder: JSONEncoder) -> some RequestBuildable {
        RequestBlock { state in
            let original = state.encoder
            defer { state.encoder = original }
            state.encoder = encoder
            try transform(state)
        }
    }
}
