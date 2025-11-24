public protocol RequestBuildable {
    associatedtype Body: RequestBuildable
    @RequestBuilder var body: Body { get }
}

extension RequestBuildable {
    var transformRequest: RequestTransformationClosure {
        if let s = self as? RequestTransformation {
            s.transform
        } else {
            body.transformRequest
        }
    }
}
