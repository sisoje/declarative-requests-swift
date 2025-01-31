import DeclarativeRequests
import Foundation
import Testing
import Vapor

actor MockServer {
    init() {
        app = Application(.testing)
        app.get(.catchall, use: requestHandler)
        app.post(.catchall, use: requestHandler)
        try! app.start()
    }

    let app: Application

    func requestHandler(_ req: Request) async -> String {
        let testId = req.headers.first(name: "X-Test-ID")!
        pendingRequests[testId] = req
        return "Success"
    }

    private var pendingRequests: [String: Request] = [:]

    func get(_ id: String) -> Request? {
        pendingRequests.removeValue(forKey: id)
    }

    func url() -> URL {
        let hostname = app.http.server.configuration.hostname
        let port = app.http.server.configuration.port
        return URL(string: "http://\(hostname):\(port)")!
    }

    deinit {
        app.shutdown()
    }

    static let shared = MockServer()
}

@Suite("Multipart Request Tests")
class MultipartTests: @unchecked Sendable {
    @Test("Multipart upload correctly constructs request")
    func testMultipartUpload() async throws {
        let url = await MockServer.shared.url().appending(path: "/upload")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=test", forHTTPHeaderField: "Content-Type")
        request.httpBody = "--test\r\nContent-Disposition: form-data; name=\"test\"\r\n\r\ntest content\r\n--test--".data(using: .utf8)

        let testId = UUID().uuidString
        request.setValue(testId, forHTTPHeaderField: "X-Test-ID")

        let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)
        #expect((response as! HTTPURLResponse).statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "Success")

        let vaporRequest = await MockServer.shared.get(testId)
        #expect(vaporRequest?.url.path == "/upload")
    }
}
