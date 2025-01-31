import DeclarativeRequests
import Foundation
import Testing
import Vapor

@Suite("Multipart Request Tests")
class MultipartTests {
    var app: Application!
    
    init() throws {
        app = Application(.testing)
        
        app.post("upload") { req -> String in
            let formData = try req.content.decode(TestFormData.self)
            return "Success"
        }
        
        try app.start()
    }
    
    deinit {
        app.shutdown()
    }
        
    @Test("Multipart upload correctly constructs request")
    func testMultipartUpload() async throws {
        
    }
}

struct TestFormData: Content {
    var file: File
    var metadata: String?
}
