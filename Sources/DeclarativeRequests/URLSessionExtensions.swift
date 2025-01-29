import Foundation

extension URLSession {
    func builderData(@RequestBuilder builder: () -> RequestBuilderNode) async throws -> (Data, URLResponse) {
        try await data(for: .init(builder: builder))
    }
}
