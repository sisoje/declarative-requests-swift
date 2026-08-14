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
