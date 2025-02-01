import DeclarativeRequests
import Foundation
import Testing
import Vapor

actor MockServer {
    init() {
        app = Application(.testing)
        app.http.server.configuration.port = .zero
        app.get(.catchall, use: requestHandler)
        app.post(.catchall, use: requestHandler)
        try! app.start()
    }

    let app: Application

    func requestHandler(_ req: Request) async -> Response {
        let testId = UUID().uuidString
        pendingRequests[testId] = req
        return Response(
            status: .ok,
            version: .http1_1,
            headers: ["X-Test-ID": testId],
            body: "Success"
        )
    }

    private var pendingRequests: [String: Request] = [:]

    func get(_ id: String) -> Request? {
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

private func getServerRequest(_ response: HTTPURLResponse) async throws -> Request? {
    let testID = response.value(forHTTPHeaderField: "X-Test-ID")!
    return await MockServer.shared.get(testID)
}

@Test("Multipart upload correctly constructs request")
func testMultipartUpload() async throws {
    let url = await MockServer.shared.baseUrl

    let request = try url.buildRequest {
        Method.POST
        Endpoint("/upload")
        Header.setCustom("Content-Type", "multipart/form-data; boundary=test")
        DataBody(
            "--test\r\nContent-Disposition: form-data; name=\"test\"\r\n\r\ntest content\r\n--test--".data(
                using: .utf8
            )!
        )
        Cookie("Key", "Value")
        Cookie("Key2", "Value2")
    }

    let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)

    #expect(String(decoding: data, as: UTF8.self) == "Success")

    let urlResponse = response as! HTTPURLResponse
    #expect(urlResponse.statusCode == 200)

    let vaporRequest = try! await getServerRequest(urlResponse)
    #expect(vaporRequest?.url.path == "/upload")
    #expect(vaporRequest?.method == .POST)
    #expect(vaporRequest?.headers.contentType?.type == "multipart")
    #expect(vaporRequest?.headers.contentType?.subType == "form-data")
    #expect(vaporRequest?.headers.contentType?.parameters["boundary"] == "test")
    #expect(vaporRequest?.headers.cookie!["Key"]?.string == "Value")
    #expect(vaporRequest?.headers.cookie!["Key2"]?.string == "Value2")

    struct TestForm: Content {
        let test: String
    }

    let form = try vaporRequest?.content.decode(TestForm.self)
    #expect(form?.test == "test content")
}
