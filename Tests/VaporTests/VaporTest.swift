import DeclarativeRequests
import Foundation
import Testing
import Vapor

@Suite("Multipart Request Tests")
class MultipartTests {
    var app: Application!
    
    init() throws {
        app = Application(.testing)
        
        app.get("upload") { req -> String in
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
        
        print(String(decoding: response.0, as: UTF8.self))
    }
}
