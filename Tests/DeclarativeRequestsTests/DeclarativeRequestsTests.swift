@testable import DeclarativeRequests
import Foundation
import Testing

@Test(arguments: [true, false]) func allowAccess(_ isAllowed: Bool) throws {
    let req = try RequestBlock {
        AllowAccess.cellular(isAllowed)
        AllowAccess.constrainedNetwork(isAllowed)
        AllowAccess.expensiveNetwork(isAllowed)
    }.request
    #expect(req.allowsCellularAccess == isAllowed)
    #expect(req.allowsExpensiveNetworkAccess == isAllowed)
    #expect(req.allowsConstrainedNetworkAccess == isAllowed)
}

@Test func baseUrlTest() throws {
    let baseUrl = try #require(URL(string: "https://google.com"))
    let request = try URLRequest(url: baseUrl) {
        Method.POST
        RequestBody.json([1])
    }
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "[1]")
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://google.com")
}

@Test func urlStringBuilderTest() throws {
    let request = try URLRequest(string: "https://google.com") {
        Method.POST
        Endpoint("/getLanguage")
        RequestBody.json([1])
        Query("languageId", "1")
    }
    #expect(request.httpMethod == "POST")
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "[1]")
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func urlStringBuilderInvalidThrows() throws {
    #expect(throws: DeclarativeRequestsError.badUrl) {
        try URLRequest(string: "") {
            Method.GET
        }
    }
}

@Test func urlRequestTest() throws {
    let request = try RequestBlock {
        Method.POST
        BaseURL("https://google.com")
        Endpoint("/getLanguage")
        RequestBody.json([1])
        Query("languageId", "1")
    }.request
    #expect(request.httpMethod == "POST")
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "[1]")
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func jsonBodyTest() throws {
    let request = try URLRequest(url: URL(fileURLWithPath: "")) {
        RequestBody.json([1])
    }
    #expect(request.httpBody == "[1]".data(using: .utf8))
}

@Test func httpMethodTest() throws {
    let request = try URLRequest(url: URL(fileURLWithPath: "")) {
        Method.custom("sisoje")
    }
    #expect(request.httpMethod == "sisoje")
}

@Test(arguments: [1, 2]) func countTest(count: Int) throws {
    let builder = RequestBlock {
        BaseURL("https://google.com")

        for i in 1 ... count {
            Endpoint("/getLanguage")
            Query("count", "\(i)")
        }
    }

    let source = RequestState()
    try builder.transform(source)
    if count == 1 {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?count=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?count=1&count=2")
    }
}

@Test(arguments: [true, false]) func ifWithoutElse(isFirst: Bool) throws {
    let builder = RequestBlock {
        BaseURL("https://google.com")

        if isFirst {
            Endpoint("/first")
            Query("isFirst", "1")
        }
    }

    let source = RequestState()
    try builder.transform(source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/first?isFirst=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com")
    }
}

@Test(arguments: [true, false]) func ifWithElse(isFirst: Bool) throws {
    let builder = RequestBlock {
        BaseURL("https://google.com")

        if isFirst {
            Endpoint("/first")
            Query("isFirst", "1")
        } else {
            Endpoint("/second")
        }
    }

    let source = RequestState()
    try builder.transform(source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/first?isFirst=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/second")
    }
}

@Test func urlEncodedBodySingleKeyValue() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded([URLQueryItem(name: "key", value: "value")])
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 1)
    #expect(items[0].name == "key")
    #expect(items[0].value == "value")
}

@Test func urlEncodedBodyDuplicateNames() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded([
            URLQueryItem(name: "color", value: "red"),
            URLQueryItem(name: "color", value: "blue"),
            URLQueryItem(name: "size", value: "large"),
        ])
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 3)
    #expect(items.filter { $0.name == "color" }.count == 2)
    #expect(items.contains(where: { $0.name == "color" && $0.value == "red" }))
    #expect(items.contains(where: { $0.name == "color" && $0.value == "blue" }))
    #expect(items.contains(where: { $0.name == "size" && $0.value == "large" }))
}

@Test func urlEncodedBodyDictionary() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded(["name": "john", "age": "25"])
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 2)
    #expect(items.contains(where: { $0.name == "name" && $0.value == "john" }))
    #expect(items.contains(where: { $0.name == "age" && $0.value == "25" }))
}

@Test func urlEncodedBodyEncodable() throws {
    struct User: Codable {
        let id: Int
        let name: String
    }
    let builder = RequestBlock {
        RequestBody.urlEncoded(User(id: 123, name: "john"))
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 2)
    #expect(items.contains(where: { $0.name == "id" && $0.value == "123" }))
    #expect(items.contains(where: { $0.name == "name" && $0.value == "john" }))
}

@Test func urlEncodedBodyLastWins() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded([URLQueryItem(name: "first", value: "1")])
        RequestBody.urlEncoded([URLQueryItem(name: "second", value: "2")])
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 1)
    #expect(items[0].name == "second")
    #expect(items[0].value == "2")
}

@Test func urlEncodedBodyBuiltFromLoop() throws {
    let items = (1 ... 6).map { URLQueryItem(name: "count", value: "\($0)") }
    let builder = RequestBlock {
        RequestBody.urlEncoded(items)
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let parsed = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(parsed.count == 6)
    #expect(parsed.filter { $0.name == "count" }.count == 6)
    for i in 1 ... 6 {
        #expect(parsed.contains(where: { $0.name == "count" && $0.value == "\(i)" }))
    }
}

@Test func queryEncodable() throws {
    struct User: Codable {
        let id: Int
        let name: String
    }
    let builder = RequestBlock {
        Query(User(id: 123, name: "john"))
    }
    let source = RequestState()
    try builder.transform(source)
    let queryItems = URLComponents(url: source.request.url!, resolvingAgainstBaseURL: true)!.queryItems!

    #expect(queryItems.contains(where: { $0.name == "id" && $0.value == "123" }))
    #expect(queryItems.contains(where: { $0.name == "name" && $0.value == "john" }))
    #expect(queryItems.count == 2)
}

@Test func repositoryExample() throws {
    struct Repository {
        @RequestBuilder var refreshToken: (_ accessToken: String) -> any RequestBuildable
        @RequestBuilder var getUser: (String) -> any RequestBuildable
    }
    let repository = Repository(
        refreshToken: { accessToken in
            Method.POST
            Endpoint("/refreshToken")
            RequestBody.json(["token": accessToken])
        },
        getUser: { userId in
            Method.GET
            Endpoint("/user")
            Query("userId", userId)
        }
    )
    let request = try repository.getUser("1").request
    #expect(request.url?.absoluteString == "/user?userId=1")
    #expect(request.httpMethod == "GET")
    let request2 = try repository.refreshToken("1").request
    #expect(request2.url?.absoluteString == "/refreshToken")
    #expect(request2.httpMethod == "POST")
    #expect(request2.httpBody.map { String(decoding: $0, as: UTF8.self) } == "{\"token\":\"1\"}")
}

@Test func stream() throws {
    let data = Data("sisoje".utf8)
    let request = try RequestBlock {
        RequestBody.stream(InputStream(data: data))
    }.request
    #expect(request.httpBodyStream != nil)
    request.httpBodyStream?.open()
    var buffer: [UInt8] = .init(repeating: 0, count: data.count)
    request.httpBodyStream?.read(&buffer, maxLength: buffer.count)
    #expect(Data(buffer) == data)
}

@Test func queryModel() throws {
    struct Model: Codable {
        var str2 = "2"
        var num1: Int?
        var num2 = 2
        var b = true
    }
    let request = try Query(Model()).request
    let rs = RequestState(request: request)
    let q1 = Set(rs.queryItems)
    let q2 = try Set(#require(URLComponents(string: "?num2=2&str2=2&b=true")?.queryItems))
    #expect(q1 == q2)
}

@Test func queryItems() throws {
    let request = try RequestBlock {
        Query("x", "y")
        Query("1", "2")
    }.request
    let rs = RequestState(request: request)
    let q1 = Set(rs.queryItems)
    let q2 = try Set(#require(URLComponents(string: "?x=y&1=2")?.queryItems))
    #expect(q1 == q2)
}

@Test func queryEnum() throws {
    enum Model: Codable {
        case some(x: Int = 5, y: String = "a")
    }
    let request = try Query(Model.some()).request
    let q1 = Set(RequestState(request: request).queryItems)
    let q2 = try Set(#require(URLComponents(string: "?x=5&y=a")?.queryItems))
    #expect(q1 == q2)
}

@Test func cookie() throws {
    let request = try RequestBlock {
        Cookie("x", "y")
        Cookie("1", "2")
    }.request
    let rs = RequestState(request: request)
    #expect(rs.cookies == ["x": "y", "1": "2"])
}

@Test func authBearer() throws {
    let request = try RequestBlock {
        Authorization.bearer("x")
    }.request
    let tok = request.value(forHTTPHeaderField: Header.Field.authorization.rawValue)
    #expect(tok == "Bearer x")
}

@Test func authUserPass() throws {
    let request = try RequestBlock {
        Authorization.basic(username: "x", password: "y")
    }.request
    let tok = request.value(forHTTPHeaderField: Header.Field.authorization.rawValue)
    #expect(tok == "Basic eDp5")
}

@Test func authCustomAuthenticator() throws {
    let request = try URLRequest {
        Method.POST
        BaseURL("https://api.example.com")
        Endpoint("/v1/data")
        Header(.accept, "application/json")
        RequestBody.json(["key": "value"])
        Authorization.custom { request in
            let bodyHash = (request.httpBody ?? Data()).count
            request.setValue("Signed \(bodyHash)", forHTTPHeaderField: "Authorization")
        }
    }
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Signed 15")
    #expect(request.httpMethod == "POST")
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
}

// MARK: - URLRequest initializer

@Test func urlRequestInitializer() throws {
    let request = try URLRequest {
        Method.POST
        BaseURL("https://api.example.com")
        Endpoint("/login")
    }
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://api.example.com/login")
}

// MARK: - Endpoint

@Test func pathAppendsToBase() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com")
        Endpoint("users", "123", "posts")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/users/123/posts")
}

@Test func pathPreservesBasePathPrefix() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/v1")
        Endpoint("users")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/v1/users")
}

@Test func pathLeadingSlashIsAbsolute() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/blabla")
        Endpoint("/test")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/test")
}

@Test func pathDotDotTraverses() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/a/b")
        Endpoint("../c")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/a/c")
}

@Test func pathDotDotFromDirectory() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/a/b/")
        Endpoint("../c")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/a/c")
}

@Test func pathSingleDotIsNoOp() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/a/b")
        Endpoint("./c")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/a/b/c")
}

@Test func pathChainsAccumulate() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com")
        Endpoint("v1")
        Endpoint("users", "123")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/v1/users/123")
}

@Test func pathSecondAbsoluteResets() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com")
        Endpoint("v1", "users")
        Endpoint("/health")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/health")
}

@Test func pathSingleSlashResetsToRoot() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/v1/users")
        Endpoint("/")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/")
}

@Test func pathPreservesQuery() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/v1")
        Query("token", "abc")
        Endpoint("users")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/v1/users?token=abc")
}

@Test func pathEmptyIsNoOp() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/v1")
        Endpoint("")
        Endpoint([])
    }
    #expect(request.url?.absoluteString == "https://api.example.com/v1")
}

@Test func pathDotDotTraversesPastBase() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/a/b/c/d")
        Endpoint("../../../g")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/a/g")
}

// MARK: - RequestBody (raw / string)

@Test func bodyDataNoContentType() throws {
    let request = try URLRequest {
        RequestBody.data(Data("hello".utf8))
    }
    #expect(request.httpBody == Data("hello".utf8))
    #expect(request.value(forHTTPHeaderField: Header.Field.contentType.rawValue) == nil)
}

@Test func bodyStringSetsPlainTextContentType() throws {
    let request = try URLRequest {
        RequestBody.string("hello")
    }
    #expect(request.httpBody == Data("hello".utf8))
    #expect(request.value(forHTTPHeaderField: Header.Field.contentType.rawValue) == "text/plain")
}

@Test func bodyExplicitContentType() throws {
    let request = try URLRequest {
        RequestBody.data(Data("<x/>".utf8), type: .XML)
    }
    #expect(request.value(forHTTPHeaderField: Header.Field.contentType.rawValue) == "application/xml")
}

// MARK: - Header

@Test func headerSingleStringPair() throws {
    let request = try URLRequest {
        Header("X-Trace-Id", "abc123")
    }
    #expect(request.value(forHTTPHeaderField: "X-Trace-Id") == "abc123")
}

@Test func headerSingleFieldPair() throws {
    let request = try URLRequest {
        Header(.referer, "https://example.com")
    }
    #expect(request.value(forHTTPHeaderField: "Referer") == "https://example.com")
}

@Test func headerNilValueIsNoOp() throws {
    let request = try URLRequest {
        Header(.userAgent, "first/1.0")
        Header(.userAgent, nil)
    }
    #expect(request.value(forHTTPHeaderField: "User-Agent") == "first/1.0")
}

@Test func headerAddModeAppends() throws {
    let request = try URLRequest {
        Header(.accept, "application/json")
        Header(.accept, "text/html", mode: .add)
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,text/html")
}

@Test func headerFromEncodableModel() throws {
    struct ApiHeaders: Codable {
        let userAgent: String
        let acceptLanguage: String

        enum CodingKeys: String, CodingKey {
            case userAgent = "User-Agent"
            case acceptLanguage = "Accept-Language"
        }
    }
    let request = try URLRequest {
        Header(ApiHeaders(userAgent: "test/1.0", acceptLanguage: "en"))
    }
    #expect(request.value(forHTTPHeaderField: "User-Agent") == "test/1.0")
    #expect(request.value(forHTTPHeaderField: "Accept-Language") == "en")
}

@Test func headerFromEncodableModelStringifiesPrimitives() throws {
    struct Mixed: Codable {
        let count: Int
        let enabled: Bool
        let label: String
    }
    let request = try URLRequest {
        Header(Mixed(count: 42, enabled: true, label: "hello"))
    }
    #expect(request.value(forHTTPHeaderField: "count") == "42")
    #expect(request.value(forHTTPHeaderField: "enabled") == "true")
    #expect(request.value(forHTTPHeaderField: "label") == "hello")
}

@Test func headerFromEncodableModelOmitsNilOptionals() throws {
    struct WithOptional: Codable {
        let name: String
        let trace: String?
    }
    let request = try URLRequest {
        Header(WithOptional(name: "alice", trace: nil))
    }
    #expect(request.value(forHTTPHeaderField: "name") == "alice")
    #expect(request.value(forHTTPHeaderField: "trace") == nil)
}

@Test func headerFromEncodableModelRejectsNested() {
    struct Nested: Codable {
        let pagination: [String: Int]
    }
    #expect {
        _ = try URLRequest {
            Header(Nested(pagination: ["page": 1]))
        }
    } throws: { error in
        if case DeclarativeRequestsError.encodingFailed = error { return true }
        return false
    }
}

@Test func headerFromFieldMap() throws {
    let request = try URLRequest {
        Header([
            .accept: "application/json",
            .userAgent: "test/1.0",
        ])
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    #expect(request.value(forHTTPHeaderField: "User-Agent") == "test/1.0")
}

@Test func headerFromStringMap() throws {
    let request = try URLRequest {
        Header([
            "X-Trace-Id": "abc123",
            "X-Custom": "value",
        ])
    }
    #expect(request.value(forHTTPHeaderField: "X-Trace-Id") == "abc123")
    #expect(request.value(forHTTPHeaderField: "X-Custom") == "value")
}

// MARK: - RequestBody.multipart (in-memory)

@Test func multipartBodyHasFormDataContentType() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "user", value: "alice")
        }
    }
    let contentType = request.value(forHTTPHeaderField: "Content-Type")
    #expect(contentType == "multipart/form-data; boundary=TEST")
}

@Test func multipartBodyContainsField() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "name", value: "alice")
        }
    }
    let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
    #expect(body.contains("--TEST\r\n"))
    #expect(body.contains("Content-Disposition: form-data; name=\"name\"\r\n\r\nalice\r\n"))
    #expect(body.hasSuffix("--TEST--\r\n"))
}

@Test func multipartBodyContainsFileData() throws {
    let payload = Data([0x89, 0x50, 0x4E, 0x47])
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.data(name: "avatar", filename: "a.png", data: payload, type: .PNG)
        }
    }
    let body = request.httpBody ?? Data()
    let head = String(decoding: body, as: UTF8.self)
    #expect(head.contains("Content-Disposition: form-data; name=\"avatar\"; filename=\"a.png\""))
    #expect(head.contains("Content-Type: image/png"))
    #expect(body.range(of: payload) != nil)
}

@Test func multipartBuilderSupportsConditionalsAndLoops() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "always", value: "yes")
            if true {
                MultipartPart.field(name: "conditional", value: "maybe")
            }
            for tag in ["a", "b"] {
                MultipartPart.field(name: "tag", value: tag)
            }
        }
    }
    let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
    #expect(body.contains("name=\"always\"\r\n\r\nyes"))
    #expect(body.contains("name=\"conditional\"\r\n\r\nmaybe"))
    #expect(body.contains("name=\"tag\"\r\n\r\na"))
    #expect(body.contains("name=\"tag\"\r\n\r\nb"))
}

@Test func multipartFileFromURL() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("multipart-test-\(UUID().uuidString).bin")
    let payload = Data("file-bytes".utf8)
    try payload.write(to: tmp)
    defer { try? FileManager.default.removeItem(at: tmp) }

    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.file(name: "doc", fileURL: tmp, type: .Stream)
        }
    }
    let body = request.httpBody ?? Data()
    let text = String(decoding: body, as: UTF8.self)
    #expect(text.contains("filename=\"\(tmp.lastPathComponent)\""))
    #expect(body.range(of: payload) != nil)
}

@Test func multipartMissingFileThrows() throws {
    let missing = URL(fileURLWithPath: "/definitely/not/here-\(UUID().uuidString).bin")
    #expect {
        _ = try URLRequest {
            RequestBody.multipart {
                MultipartPart.file(name: "doc", fileURL: missing)
            }
        }
    } throws: { error in
        if case DeclarativeRequestsError.badMultipart = error { return true }
        return false
    }
}

// MARK: - RequestBody.multipart (streamed)

@Test func streamedMultipartSetsHttpBodyStreamNotData() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST", strategy: .streamed()) {
            MultipartPart.field(name: "k", value: "v")
        }
    }
    #expect(request.httpBodyStream != nil)
    #expect(request.httpBody == nil)
}

@Test func streamedMultipartSetsContentTypeWithBoundary() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST", strategy: .streamed()) {
            MultipartPart.field(name: "k", value: "v")
        }
    }
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "multipart/form-data; boundary=TEST")
}

@Test func streamedMultipartComputesContentLength() throws {
    let inMemory = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "k", value: "v")
        }
    }
    let expected = try #require(inMemory.httpBody?.count)

    let streamed = try URLRequest {
        RequestBody.multipart(boundary: "TEST", strategy: .streamed()) {
            MultipartPart.field(name: "k", value: "v")
        }
    }
    #expect(streamed.value(forHTTPHeaderField: "Content-Length") == "\(expected)")
}

@Test func streamedMultipartMissingFileThrows() throws {
    let missing = URL(fileURLWithPath: "/definitely/not/here-\(UUID().uuidString).bin")
    #expect {
        _ = try URLRequest {
            RequestBody.multipart(strategy: .streamed()) {
                MultipartPart.file(name: "doc", fileURL: missing)
            }
        }
    } throws: { error in
        if case DeclarativeRequestsError.badMultipart = error { return true }
        return false
    }
}

@Test func streamedMultipartProducesIdenticalBytesToInMemory() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("streamed-\(UUID().uuidString).bin")
    let payload = Data((0 ..< (256 * 1024)).map { UInt8($0 & 0xFF) })
    try payload.write(to: tmp)
    defer { try? FileManager.default.removeItem(at: tmp) }

    let inMemory = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "title", value: "movie")
            MultipartPart.file(name: "video", fileURL: tmp, type: .MP4)
        }
    }
    let expected = try #require(inMemory.httpBody)

    let streamed = try URLRequest {
        RequestBody.multipart(boundary: "TEST", strategy: .streamed()) {
            MultipartPart.field(name: "title", value: "movie")
            MultipartPart.file(name: "video", fileURL: tmp, type: .MP4)
        }
    }
    let actual = try drainStream(#require(streamed.httpBodyStream), timeout: 5)

    #expect(actual == expected)
    #expect(streamed.value(forHTTPHeaderField: "Content-Length") == "\(expected.count)")
}

private func drainStream(_ stream: InputStream, timeout: TimeInterval) throws -> Data {
    let consumer = StreamConsumer(stream: stream)
    return try consumer.consume(timeout: timeout)
}

private final class StreamConsumer: NSObject, StreamDelegate {
    private let stream: InputStream
    private var collected = Data()
    private var buffer = [UInt8](repeating: 0, count: 64 * 1024)
    private var done = false
    private var error: Error?

    init(stream: InputStream) {
        self.stream = stream
    }

    func consume(timeout: TimeInterval) throws -> Data {
        stream.delegate = self
        stream.schedule(in: .current, forMode: .default)
        stream.open()

        let deadline = Date().addingTimeInterval(timeout)
        while !done, Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
        }

        stream.remove(from: .current, forMode: .default)
        stream.close()
        stream.delegate = nil

        if let error { throw error }
        if !done {
            throw DeclarativeRequestsError.badStream
        }
        return collected
    }

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream === stream else { return }
        switch eventCode {
        case .hasBytesAvailable:
            let n = stream.read(&buffer, maxLength: buffer.count)
            if n > 0 {
                collected.append(buffer, count: n)
            } else if n < 0 {
                error = stream.streamError
                done = true
            } else {
                done = true
            }
        case .endEncountered:
            done = true
        case .errorOccurred:
            error = stream.streamError
            done = true
        default:
            break
        }
    }
}

// MARK: - CachePolicy / NetworkServiceType / HTTPShouldHandleCookies

@Test func cachePolicyApplied() throws {
    let request = try URLRequest {
        CachePolicy(.reloadIgnoringLocalCacheData)
    }
    #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
}

@Test func networkServiceTypeApplied() throws {
    let request = try URLRequest {
        NetworkServiceType(.background)
    }
    #expect(request.networkServiceType == .background)
}

@Test(arguments: [true, false]) func httpShouldHandleCookiesApplied(_ flag: Bool) throws {
    let request = try URLRequest {
        HTTPShouldHandleCookies(flag)
    }
    #expect(request.httpShouldHandleCookies == flag)
}

// MARK: - curlCommand

@Test func curlCommandIncludesMethodHeadersBodyURL() throws {
    let request = try URLRequest {
        Method.POST
        BaseURL("https://api.example.com")
        Endpoint("/login")
        Header(.accept, "application/json")
        RequestBody.string("{\"user\":\"alice\"}", type: .JSON)
    }
    let curl = request.curlCommand
    #expect(curl.contains("curl"))
    #expect(curl.contains("-X POST"))
    #expect(curl.contains("'Accept: application/json'"))
    #expect(curl.contains("'Content-Type: application/json'"))
    #expect(curl.contains("--data-binary '{\"user\":\"alice\"}'"))
    #expect(curl.contains("'https://api.example.com/login'"))
}

@Test func curlCommandOmitsExplicitGet() throws {
    let request = try URLRequest {
        Method.GET
        BaseURL("https://api.example.com")
    }
    let curl = request.curlCommand
    #expect(!curl.contains("-X GET"))
}

@Test func curlCommandQuotesSingleQuotes() throws {
    let request = try URLRequest {
        RequestBody.string("don't break")
    }
    let curl = request.curlCommand
    #expect(curl.contains("'don'\\''t break'"))
}

// MARK: - LocalizedError

@Test func errorHasLocalizedDescription() {
    #expect(DeclarativeRequestsError.badUrl.errorDescription?.isEmpty == false)
    #expect(DeclarativeRequestsError.badStream.errorDescription?.isEmpty == false)
    let multipart = DeclarativeRequestsError.badMultipart(reason: "boom").errorDescription
    #expect(multipart?.contains("boom") == true)
    let encoding = DeclarativeRequestsError.encodingFailed(reason: "bad").errorDescription
    #expect(encoding?.contains("bad") == true)
}

// MARK: - EncodableQueryItems sorting

@Test func queryEncodableHasStableOrder() throws {
    struct Model: Codable {
        let zebra: String
        let alpha: String
        let mango: String
    }
    let request = try URLRequest {
        BaseURL("https://example.com")
        Query(Model(zebra: "z", alpha: "a", mango: "m"))
    }
    let query = request.url?.query
    #expect(query == "alpha=a&mango=m&zebra=z")
}

// MARK: - Header bulk-add modes

@Test func headerStringNameAddMode() throws {
    let request = try URLRequest {
        Header("Accept", "application/json")
        Header("Accept", "text/html", mode: .add)
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,text/html")
}

@Test func headerFieldMapAddMode() throws {
    let request = try URLRequest {
        Header(.accept, "application/json")
        Header([.accept: "text/html"], mode: .add)
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,text/html")
}

@Test func headerStringMapAddMode() throws {
    let request = try URLRequest {
        Header("Accept", "application/json")
        Header(["Accept": "text/html"], mode: .add)
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,text/html")
}

@Test func headerEncodableAddMode() throws {
    struct Extra: Codable {
        let accept: String
        enum CodingKeys: String, CodingKey { case accept = "Accept" }
    }
    let request = try URLRequest {
        Header(.accept, "application/json")
        Header(Extra(accept: "text/html"), mode: .add)
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,text/html")
}

// MARK: - URLRequest initializer (cache + timeout)

@Test func urlRequestInitAppliesCustomCacheAndTimeout() throws {
    let request = try URLRequest(
        url: URL(string: "https://api.example.com"),
        cachePolicy: .reloadIgnoringLocalCacheData,
        timeoutInterval: 5
    ) {
        Method.GET
    }
    #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
    #expect(request.timeoutInterval == 5)
    #expect(request.url?.absoluteString == "https://api.example.com")
}

@Test func urlRequestStringInitAppliesCustomCacheAndTimeout() throws {
    let request = try URLRequest(
        string: "https://api.example.com",
        cachePolicy: .returnCacheDataDontLoad,
        timeoutInterval: 10
    ) {
        Method.GET
    }
    #expect(request.cachePolicy == .returnCacheDataDontLoad)
    #expect(request.timeoutInterval == 10)
    #expect(request.url?.absoluteString == "https://api.example.com")
}

// MARK: - URL.buildRequest

@Test func urlBuildRequest() throws {
    let url = try #require(URL(string: "https://api.example.com"))
    let request = try url.buildRequest {
        Method.PUT
        Endpoint("/widgets/1")
    }
    #expect(request.httpMethod == "PUT")
    #expect(request.url?.absoluteString == "https://api.example.com/widgets/1")
}

// MARK: - ContentType as a block

@Test func contentTypeBlockSetsHeader() throws {
    let request = try URLRequest {
        ContentType.JSON
    }
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
}

// MARK: - Method (every standard case)

@Test func methodAppliesRawValueForAllStandardCases() throws {
    let cases: [DeclarativeRequests.Method] = [.HEAD, .PUT, .DELETE, .CONNECT, .OPTIONS, .TRACE, .PATCH]
    for method in cases {
        let request = try URLRequest { method }
        #expect(request.httpMethod == method.rawValue)
    }
}

// MARK: - curlCommand binary body

@Test func curlCommandBinaryBodyOmitted() throws {
    let binary = Data([0xFF, 0xFE, 0x00, 0x01])
    let request = try URLRequest {
        Method.POST
        BaseURL("https://api.example.com")
        RequestBody.data(binary, type: .Stream)
    }
    let curl = request.curlCommand
    #expect(curl.contains("# binary body of 4 bytes omitted"))
    #expect(!curl.contains("--data-binary"))
}
