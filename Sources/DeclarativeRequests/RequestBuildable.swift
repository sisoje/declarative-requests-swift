public protocol RequestBuildable {
    associatedtype Body: RequestBuildable
    @RequestBuilder var body: Body { get }
}

extension RequestBuildable {
    var transform: RequestTransformationClosure {
        if let s = self as? RequestTransformation {
            s._transform
        } else {
            body.transform
        }
    }
}
