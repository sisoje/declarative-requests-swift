import Foundation

extension URL {
    func build(@RequestBuilder _ builder: () -> [BuilderNode]) throws -> URLRequest {
        let initial = RequestSourceOfTruth()
        try initial.state.runBuilder {
            RequestBuilderGroup {
                RequestBuilderGroup(builder: builder)
                BaseURL(url: self)
            }
        }
        return initial.request
    }
}
