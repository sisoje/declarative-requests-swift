import Foundation

extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        var state = RequestBuilderState()
        let transformer = RequestTransformerUtils.merge(builder(), BaseURL(url: self).transformer)
        try transformer(&state)
        return state.request
    }
}
