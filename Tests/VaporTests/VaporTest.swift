import DeclarativeRequests
import Foundation
import Testing
import Vapor

@Suite("Multipart Request Tests")
class MultipartTests: @unchecked Sendable {
    static let app: Application = {
        let app = Application(.testing)
        app.get(.catchall) { req -> String in
            return "Success"
        }
        try! app.start()
        return app
    }()
        
    @Test("Multipart upload correctly constructs request")
    func testMultipartUpload() async throws {
        let response = try await URLSession.shared.data(from: URL(string: "http://localhost:8080/upload")!)
        #expect(response.0 == "Success".data(using: .utf8))
    }
}
