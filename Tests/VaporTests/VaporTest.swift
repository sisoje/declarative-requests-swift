import DeclarativeRequests
import Foundation
import Testing
import Vapor

actor RequestForwarder {
    static let shared = RequestForwarder()
    
    private var pendingRequests: [String: CheckedContinuation<Request, Error>] = [:]
    
    func waitForRequest(id: String) async throws -> Request {
        try await withCheckedThrowingContinuation { continuation in
            pendingRequests[id] = continuation
        }
    }
    
    func forward(_ request: Request, id: String) async {
        if let continuation = pendingRequests.removeValue(forKey: id) {
            continuation.resume(returning: request)
        }
    }
}

@Suite("Multipart Request Tests")
class MultipartTests: @unchecked Sendable {
    static func requestHandler(_ req: Request) async throws -> String {
        guard let testId = req.headers.first(name: "X-Test-ID") else {
            throw Abort(.badRequest, reason: "Missing test identifier")
        }
        
        await RequestForwarder.shared.forward(req, id: testId)
        return "Success"
    }
    
    static let app: Application = {
        let app = Application(.testing)
        app.get(.catchall, use: MultipartTests.requestHandler)
        app.post(.catchall, use: MultipartTests.requestHandler)
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
        let testId = UUID().uuidString
        let requestTask = Task {
            try await RequestForwarder.shared.waitForRequest(id: testId)
        }

        var request = URLRequest(url: url(path: "/upload"))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=test", forHTTPHeaderField: "Content-Type")
        request.setValue(testId, forHTTPHeaderField: "X-Test-ID")
        request.httpBody = "--test\r\nContent-Disposition: form-data; name=\"test\"\r\n\r\ntest content\r\n--test--".data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        #expect((response as! HTTPURLResponse).statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "Success")
        
        let vaporRequest = try await requestTask.value
        #expect(vaporRequest.url.path == "/upload")
    }
    
    deinit {
        Self.app.shutdown()
    }
}
