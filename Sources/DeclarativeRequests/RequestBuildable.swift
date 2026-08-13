import Foundation

public protocol RequestBuildable {
    associatedtype Body: RequestBuildable
    @RequestBuilder var body: Body { get }
}

public extension RequestBuildable {
    var request: URLRequest {
        get throws {
            let state = RequestState()
            try transform(state)
            return state.request
        }
    }
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
