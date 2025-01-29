import Foundation

extension URLSession {
    func builderData(@RequestBuilder builder: () -> BuilderNode) async throws -> (Data, URLResponse) {
        try await data(for: .init(builder: builder))
    }
}
