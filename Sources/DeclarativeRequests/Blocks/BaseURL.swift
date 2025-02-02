import Foundation

extension URL: CompositeNode {
    public var body: some BuilderNode {
        RequestState[\RequestState.baseURL, self]
    }
}
