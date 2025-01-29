import Foundation

extension URLSession {
    func builderData(@RequestBuilder builder: () -> RequestBuilderRootNode) async throws -> (Data, URLResponse) {
        try await data(for: .init(builder: builder))
    }
}
