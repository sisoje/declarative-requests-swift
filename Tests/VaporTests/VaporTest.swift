import DeclarativeRequests
import Foundation
import Testing
import Vapor

struct VaporTests {
    let server: MockServer

    init() async throws {
        server = try await MockServer.make()
    }

    @Test("Multipart upload sends correct wire bytes")
    func multipartUpload() async throws {
        let request = try server.app.baseUrl.buildRequest {
            Method.POST
            Endpoint("/upload")

            RequestBody.multipart {
                MultipartPart.field(name: "test", value: "test content")
            }

            Cookie("Key", "Value")
            Cookie("Key2", "Value2")
        }

        let (_, response) = try await URLSession.shared.data(for: request)
        let (vaporRequest, vaporResponse, err) = await server.interceptor.get(response)
        #expect(vaporResponse.status.code == 500)
        #expect(err?.localizedDescription == "RouteNotFound.404: Not Found")
        #expect((response as? HTTPURLResponse)?.statusCode == 500)
        #expect(vaporRequest.url.path == "/upload")
        #expect(vaporRequest.method == .POST)
        #expect(vaporRequest.headers.contentType?.type == "multipart")
        #expect(vaporRequest.headers.contentType?.subType == "form-data")
        #expect(vaporRequest.headers.contentType?.parameters["boundary"]?.isEmpty == false)
        #expect(vaporRequest.headers.cookie?["Key"]?.string == "Value")
        #expect(vaporRequest.headers.cookie?["Key2"]?.string == "Value2")

        struct TestForm: Content {
            let test: String
        }
        let form = try vaporRequest.content.decode(TestForm.self)
        #expect(form.test == "test content")
    }

    @Test("JSON body arrives parseable on the wire with correct Content-Type")
    func jsonBodyWireFormat() async throws {
        struct Payload: Codable, Equatable, Content {
            let name: String
            let count: Int
        }
        let payload = Payload(name: "alice", count: 42)

        let request = try server.app.baseUrl.buildRequest {
            Method.POST
            Endpoint("/echo-json")
            RequestBody.json(payload)
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        let (vaporRequest, _, _) = await server.interceptor.get(response)

        #expect(vaporRequest.headers.contentType?.type == "application")
        #expect(vaporRequest.headers.contentType?.subType == "json")
        let decoded = try vaporRequest.content.decode(Payload.self)
        #expect(decoded == payload)
    }

    @Test("URL-encoded body arrives parseable on the wire")
    func urlEncodedBodyWireFormat() async throws {
        let request = try server.app.baseUrl.buildRequest {
            Method.POST
            Endpoint("/echo-form")
            RequestBody.urlEncoded([
                URLQueryItem(name: "grant_type", value: "password"),
                URLQueryItem(name: "username", value: "alice"),
                URLQueryItem(name: "tag", value: "swift"),
                URLQueryItem(name: "tag", value: "ios"),
            ])
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        let (vaporRequest, _, _) = await server.interceptor.get(response)

        #expect(vaporRequest.headers.contentType?.type == "application")
        #expect(vaporRequest.headers.contentType?.subType == "x-www-form-urlencoded")
        let body = vaporRequest.body.string ?? ""
        #expect(body.contains("grant_type=password"))
        #expect(body.contains("username=alice"))
        #expect(body.contains("tag=swift"))
        #expect(body.contains("tag=ios"))
    }

    @Test("Headers reach the server with their canonical names")
    func headerNamesOnWire() async throws {
        let request = try server.app.baseUrl.buildRequest {
            Method.GET
            Endpoint("/echo-headers")
            Header.accept.setValue("application/json")
            Header.userAgent.setValue("DeclarativeRequests/1.0")
            Header.custom("X-Trace-Id").setValue("abc123")
            Header.accept.addValue("text/html")
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        let (vaporRequest, _, _) = await server.interceptor.get(response)

        let accept = vaporRequest.headers["Accept"].joined(separator: ",")
        #expect(accept.contains("application/json"))
        #expect(accept.contains("text/html"))
        #expect(vaporRequest.headers["User-Agent"].first == "DeclarativeRequests/1.0")
        #expect(vaporRequest.headers["X-Trace-Id"].first == "abc123")
    }

    @Test("Multipart binary file round-trips byte-perfect through Vapor (in-memory + streamed)")
    func multipartBinaryFileRoundTrip() async throws {
        let bytes: [UInt8] = (0 ..< (256 * 1024)).map { i in
            UInt8((i &* 31 &+ 7) & 0xFF)
        }
        let payload = Data(bytes)
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("vapor-roundtrip-\(UUID().uuidString).bin")
        try payload.write(to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        for strategy in [RequestBody.MultipartStrategy.inMemory, .streamed()] {
            let request = try server.app.baseUrl.buildRequest {
                Method.POST
                Endpoint("/upload")
                RequestBody.multipart(boundary: "BNDY", strategy: strategy) {
                    MultipartPart.field(name: "title", value: "snapshot")
                    MultipartPart.file(name: "blob", fileURL: tmp, type: .Stream)
                }
            }
            let (_, response) = try await URLSession.shared.data(for: request)
            let (vReq, _, _) = await server.interceptor.get(response)

            let body = bodyBytes(of: vReq)
            let bodyText = String(decoding: body, as: UTF8.self)

            #expect(body.count > payload.count, "body should wrap payload: got \(body.count) bytes")
            #expect(bodyText.contains("name=\"title\""))
            #expect(bodyText.contains("snapshot"))
            #expect(bodyText.contains("name=\"blob\""))
            #expect(bodyText.contains("filename=\"\(tmp.lastPathComponent)\""))
            #expect(bodyText.contains("Content-Type: application/octet-stream"))
            #expect(body.range(of: payload) != nil, "payload bytes were corrupted on the wire")
            #expect(body.range(of: Data("--BNDY--\r\n".utf8)) != nil, "missing closing boundary")
        }
    }

    @Test("Multipart preserves multiple file parts on the wire")
    func multipartMultipleFiles() async throws {
        let a = FileManager.default.temporaryDirectory.appendingPathComponent("a-\(UUID().uuidString).bin")
        let b = FileManager.default.temporaryDirectory.appendingPathComponent("b-\(UUID().uuidString).bin")
        let aBytes = Data("first file content — éàü 漢字".utf8)
        let bBytes = Data([UInt8](repeating: 0xAB, count: 4096))
        try aBytes.write(to: a)
        try bBytes.write(to: b)
        defer {
            try? FileManager.default.removeItem(at: a)
            try? FileManager.default.removeItem(at: b)
        }

        let request = try server.app.baseUrl.buildRequest {
            Method.POST
            Endpoint("/upload-multi")
            RequestBody.multipart(boundary: "MULTI") {
                MultipartPart.field(name: "user", value: "alice")
                MultipartPart.file(name: "first", fileURL: a, type: .PlainText)
                MultipartPart.file(name: "second", fileURL: b, type: .Stream)
            }
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        let (vReq, _, _) = await server.interceptor.get(response)

        let body = bodyBytes(of: vReq)
        let bodyText = String(decoding: body, as: UTF8.self)
        #expect(bodyText.contains("name=\"user\""))
        #expect(bodyText.contains("alice"))
        #expect(bodyText.contains("name=\"first\""))
        #expect(bodyText.contains("name=\"second\""))
        #expect(bodyText.contains("filename=\"\(a.lastPathComponent)\""))
        #expect(bodyText.contains("filename=\"\(b.lastPathComponent)\""))
        #expect(bodyText.contains("Content-Type: text/plain"))
        #expect(bodyText.contains("Content-Type: application/octet-stream"))
        #expect(body.range(of: aBytes) != nil)
        #expect(body.range(of: bBytes) != nil)
    }
}

// MARK: - Helpers

private func bodyBytes(of request: Request) -> Data {
    guard let buffer = request.body.data else { return Data() }
    return buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) ?? Data()
}

// MARK: - URLSession DSL extensions

struct URLSessionExtensionTests {
    let server: EchoServer

    init() async throws {
        server = try await EchoServer.make()
    }

    @Test("URLSession.data { … } sends the built request and returns the response")
    func sessionDataExtension() async throws {
        let baseURL = server.app.baseUrl
        let request = try URLRequest {
            Method.GET
            BaseURL(baseURL)
            Endpoint("/ping")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "pong")
    }

    @Test("URLSession.decode(_:_:) decodes a JSON response")
    func sessionDecodeExtension() async throws {
        let baseURL = server.app.baseUrl
        let request = try URLRequest {
            Method.GET
            BaseURL(baseURL)
            Endpoint("/users/42")
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        let user = try JSONDecoder().decode(EchoServer.User.self, from: data)
        #expect(user.id == 42)
        #expect(user.name == "User-42")
    }

    @Test("URLSession.decode(_:_:) round-trips a JSON request body through a JSON response")
    func sessionDecodeRoundTripsJSONBody() async throws {
        let baseURL = server.app.baseUrl
        let payload = EchoServer.Echo(message: "hello", count: 7)
        let request = try URLRequest {
            Method.POST
            BaseURL(baseURL)
            Endpoint("/echo")
            RequestBody.json(payload)
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        let echoed = try JSONDecoder().decode(EchoServer.Echo.self, from: data)
        #expect(echoed == payload)
    }
}
