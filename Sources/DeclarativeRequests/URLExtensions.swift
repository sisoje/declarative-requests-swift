import Foundation
import SwiftUI

extension URL {
    func request(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        var state = RequestBuilderState()
        let baseUrlTransformer = BaseURL(url: self).transformer
        let transformer = Transformer.merge(builder(), baseUrlTransformer)
        try transformer(&state)
        return state.request
    }
}
