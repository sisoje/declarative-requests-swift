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
    
    private func url(path: String) -> URL {
        let hostname = Self.app.http.server.configuration.hostname
        let port = Self.app.http.server.configuration.port
        return URL(string: "http://\(hostname):\(port)\(path)")!
    }
    
    @Test("Multipart upload correctly constructs request")
    func testMultipartUpload() async throws {
        let response = try await URLSession.shared.data(from: url(path: "/upload"))
        #expect(response.0 == "Success".data(using: .utf8))
    }
}
