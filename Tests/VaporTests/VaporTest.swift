import DeclarativeRequests
import Foundation
import Testing
import Vapor

@Suite("Multipart Request Tests")
class MultipartTests: @unchecked Sendable {
    var app: Application!
    var receivedRequest: Request?
    
    init() throws {
        app = Application(.testing)

        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 8080

        app.get("upload") { [weak self] req -> String in
            self?.receivedRequest = req
            return "Success"
        }
        
        try app.start()
    }
    
    deinit {
        app.shutdown()
    }
        
    @Test("Multipart upload correctly constructs request")
    func testMultipartUpload() async throws {
        let response = try await URLSession.shared.data(from: URL(string: "http://localhost:8080/upload")!)
        #expect(response.0 == "Success".data(using: .utf8))
        
        // TODO: check receivedRequest
    }
}
