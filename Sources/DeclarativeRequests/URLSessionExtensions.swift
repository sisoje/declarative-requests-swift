import Foundation

extension URLSession {
    func builderData(@RequestBuilder builder: () -> RequestTransformer) async throws -> (Data, URLResponse) {
        try await data(for: .init(builder: builder))
    }
}
