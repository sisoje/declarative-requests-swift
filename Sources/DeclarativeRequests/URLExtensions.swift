import Foundation
import SwiftUI

extension URL {
    func request(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        var state = RequestBuilderState()
        let baseUrlTransformer = Transformer.oneNode(BaseURL(url: self))
        let transformer = Transformer.merge(builder(), baseUrlTransformer)
        try transformer(&state)
        return state.request
    }
}
