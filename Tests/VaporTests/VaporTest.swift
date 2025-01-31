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
        let testId = UUID().uuidString
        pendingRequests[testId.data(using: .utf8)!] = req
        return testId
    }

    private var pendingRequests: [Data: Request] = [:]

    func get(_ id: Data) -> Request? {
        pendingRequests.removeValue(forKey: id)
    }

    var baseUrl: URL {
        let config = app.http.server.configuration
        var c = URLComponents()
        c.scheme = "http"
        c.host = config.hostname
        c.port = config.port
        return c.url!
    }

    deinit {
        app.shutdown()
    }

    static let shared = MockServer()
}

@Test("Multipart upload correctly constructs request")
func testMultipartUpload() async throws {
    let url = await MockServer.shared.baseUrl.appending(path: "upload")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=test", forHTTPHeaderField: "Content-Type")
    request.httpBody = "--test\r\nContent-Disposition: form-data; name=\"test\"\r\n\r\ntest content\r\n--test--".data(using: .utf8)

    let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)
    #expect((response as! HTTPURLResponse).statusCode == 200)
    let vaporRequest = await MockServer.shared.get(data)
    #expect(vaporRequest?.url.path == "/upload")
}
