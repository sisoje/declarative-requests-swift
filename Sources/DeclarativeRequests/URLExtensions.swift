import Foundation

extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        var state = RequestBuilderState()
        let baseUrlTransformer = BaseURL(url: self).transformer
        let transformer = RequestTransformerUtils.merge(builder(), baseUrlTransformer)
        try transformer(&state)
        return state.request
    }
}
