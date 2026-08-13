@testable import DeclarativeRequests
import Foundation
import Testing

@Test(arguments: [true, false]) func allowAccess(_ isAllowed: Bool) throws {
    let req = try RequestBlock {
        RequestMutation[\.allowsCellularAccess, isAllowed]
        RequestMutation[\.allowsConstrainedNetworkAccess, isAllowed]
        RequestMutation[\.allowsExpensiveNetworkAccess, isAllowed]
    }.request
    #expect(req.allowsCellularAccess == isAllowed)
    #expect(req.allowsExpensiveNetworkAccess == isAllowed)
    #expect(req.allowsConstrainedNetworkAccess == isAllowed)
}

@Test func baseUrlTest() throws {
    let baseUrl = try #require(URL(string: "https://google.com"))
    let request = try URLRequest {
        BaseURL(baseUrl)
        Method.POST
        RequestBody.json([1])
    }
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "[1]")
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://google.com")
}

@Test func urlStringBuilderTest() throws {
    let request = try URLRequest {
        BaseURL("https://google.com")
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
        try URLRequest {
            BaseURL("")
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
    let request = try URLRequest {
        RequestBody.json([1])
    }
    #expect(request.httpBody == "[1]".data(using: .utf8))
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
}

@Test func httpMethodTest() throws {
    let request = try URLRequest {
        RequestMutation[\.httpMethod, "sisoje"]
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
        RequestBody.urlEncoded("key", "value")
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 1)
    #expect(items[0].name == "key")
    #expect(items[0].value == "value")
    #expect(source.request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
}

@Test func urlEncodedBodyDuplicateNames() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded("color", "red")
        RequestBody.urlEncoded("color", "blue")
        RequestBody.urlEncoded("size", "large")
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

@Test func urlEncodedBodiesMerge() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded("first", "1")
        RequestBody.urlEncoded("second", "2")
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 2)
    #expect(items.contains(where: { $0.name == "first" && $0.value == "1" }))
    #expect(items.contains(where: { $0.name == "second" && $0.value == "2" }))
}

@Test func urlEncodedBodyEscapesPlus() throws {
    let builder = RequestBlock {
        RequestBody.urlEncoded("expr", "1+2")
    }
    let source = RequestState()
    try builder.transform(source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) }
    #expect(body == "expr=1%2B2")
    #expect(source.encodedBodyItems == [URLQueryItem(name: "expr", value: "1+2")])
}

@Test func urlEncodedBodyBuiltFromLoop() throws {
    let builder = RequestBlock {
        for i in 1 ... 6 {
            RequestBody.urlEncoded("count", "\(i)")
        }
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
    let url = try #require(source.request.url)
    let queryItems = try #require(URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems)

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
    let url = try #require(request.url)
    let rs = try #require(URLComponents(url: url, resolvingAgainstBaseURL: true))
    let q1 = try Set(#require(rs.queryItems))
    let q2comps = try #require(URLComponents(string: "?num2=2&str2=2&b=true"))
    let q2 = try Set(#require(q2comps.queryItems))
    #expect(q1 == q2)
}

@Test func queryItems() throws {
    let request = try RequestBlock {
        Query("x", "y")
        Query("1", "2")
    }.request
    let url = try #require(request.url)
    let rs = try #require(URLComponents(url: url, resolvingAgainstBaseURL: true))
    let q1 = try Set(#require(rs.queryItems))
    let q2comps = try #require(URLComponents(string: "?x=y&1=2"))
    let q2 = try Set(#require(q2comps.queryItems))
    #expect(q1 == q2)
}

@Test func queryEnum() throws {
    enum Model: Codable {
        case some(x: Int = 5, y: String = "a")
    }
    let request = try Query(Model.some()).request
    let url = try #require(request.url)
    let rs = try #require(URLComponents(url: url, resolvingAgainstBaseURL: true))
    let q1 = try Set(#require(rs.queryItems))
    let q2comps = try #require(URLComponents(string: "?x=5&y=a"))
    let q2 = try Set(#require(q2comps.queryItems))
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
    let tok = request.value(forHTTPHeaderField: Header.authorization.rawValue)
    #expect(tok == "Bearer x")
}

@Test func authUserPass() throws {
    let request = try RequestBlock {
        Authorization.basic(username: "x", password: "y")
    }.request
    let tok = request.value(forHTTPHeaderField: Header.authorization.rawValue)
    #expect(tok == "Basic eDp5")
}

@Test func computedAuthOverBuiltRequest() throws {
    let request = try URLRequest {
        Method.POST
        BaseURL("https://api.example.com")
        Endpoint("/v1/data")
        Header.accept.setValue("application/json")
        RequestBody.json(["key": "value"])
        RequestBlock { state in
            let bodyLength = (state.request.httpBody ?? Data()).count
            state.request.setValue("Signed \(bodyLength)", forHTTPHeaderField: "Authorization")
        }
    }
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Signed 15")
    #expect(request.httpMethod == "POST")
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
}

// MARK: - Endpoint

@Test func pathAppendsToBase() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com")
        Endpoint("/users/123/posts")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/users/123/posts")
}

@Test func pathPreservesBasePathPrefix() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com/v1")
        Endpoint("/v1/users")
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

@Test func pathSecondAbsoluteResets() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com")
        Endpoint("/v1/users")
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
        Endpoint("/v1/users")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/v1/users?token=abc")
}

// MARK: - RequestBody (raw / string)

@Test func bodyDataNoContentType() throws {
    let request = try URLRequest {
        RequestBody.data(Data("hello".utf8))
    }
    #expect(request.httpBody == Data("hello".utf8))
    #expect(request.value(forHTTPHeaderField: Header.contentType.rawValue) == nil)
}

@Test func bodyStringSetsPlainTextContentType() throws {
    let request = try URLRequest {
        RequestBody.string("hello")
    }
    #expect(request.httpBody == Data("hello".utf8))
    #expect(request.value(forHTTPHeaderField: Header.contentType.rawValue) == "text/plain")
}

@Test func bodyExplicitContentType() throws {
    let request = try URLRequest {
        RequestBody.data(Data("<x/>".utf8), type: "application/xml")
    }
    #expect(request.value(forHTTPHeaderField: Header.contentType.rawValue) == "application/xml")
}

// MARK: - Header

@Test func headerSingleStringPair() throws {
    let request = try URLRequest {
        Header.custom("X-Trace-Id").setValue("abc123")
    }
    #expect(request.value(forHTTPHeaderField: "X-Trace-Id") == "abc123")
}

@Test func headerSingleFieldPair() throws {
    let request = try URLRequest {
        Header.referer.setValue("https://example.com")
    }
    #expect(request.value(forHTTPHeaderField: "Referer") == "https://example.com")
}

@Test func headerSetValueOverrides() throws {
    let request = try URLRequest {
        Header.userAgent.setValue("first/1.0")
        Header.userAgent.setValue("second/2.0")
    }
    #expect(request.value(forHTTPHeaderField: "User-Agent") == "second/2.0")
}

@Test func headerAddModeAppends() throws {
    let request = try URLRequest {
        Header.accept.setValue("application/json")
        Header.accept.addValue("text/html")
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,text/html")
}

@Test func headerMultipleFieldValues() throws {
    let request = try URLRequest {
        Header.userAgent.setValue("test/1.0")
        Header.acceptLanguage.setValue("en")
    }
    #expect(request.value(forHTTPHeaderField: "User-Agent") == "test/1.0")
    #expect(request.value(forHTTPHeaderField: "Accept-Language") == "en")
}

@Test func headerCustomFieldValues() throws {
    let request = try URLRequest {
        Header.custom("count").setValue("42")
        Header.custom("enabled").setValue("true")
        Header.custom("label").setValue("hello")
    }
    #expect(request.value(forHTTPHeaderField: "count") == "42")
    #expect(request.value(forHTTPHeaderField: "enabled") == "true")
    #expect(request.value(forHTTPHeaderField: "label") == "hello")
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
            MultipartPart.data(name: "avatar", filename: "a.png", data: payload, type: "image/png")
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
            MultipartPart.file(name: "doc", fileURL: tmp, type: "application/octet-stream")
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

// MARK: - RFC 7578 escaping & boundary quoting

@Test func multipartEscapesQuoteInFieldName() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "weird\"name", value: "v")
        }
    }
    let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
    #expect(body.contains("name=\"weird\\\"name\""))
}

@Test func multipartEscapesBackslashInFilename() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.data(name: "f", filename: "a\\b.bin", data: Data("x".utf8))
        }
    }
    let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
    #expect(body.contains("filename=\"a\\\\b.bin\""))
}

@Test func multipartStripsCRLFInName() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "a\r\nX-Injected: y", value: "v")
        }
    }
    let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
    #expect(body.contains("name=\"aX-Injected: y\""))
    #expect(!body.contains("\r\nX-Injected"))
}

@Test func multipartQuotesBoundaryWithSpaceInContentType() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "with space") {
            MultipartPart.field(name: "k", value: "v")
        }
    }
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "multipart/form-data; boundary=\"with space\"")
}

@Test func multipartDoesNotQuoteSimpleBoundary() throws {
    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.field(name: "k", value: "v")
        }
    }
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "multipart/form-data; boundary=TEST")
}

@Test func multipartMultipleFilesWithSameName() throws {
    let a = FileManager.default.temporaryDirectory.appendingPathComponent("rfc-a-\(UUID().uuidString).bin")
    let b = FileManager.default.temporaryDirectory.appendingPathComponent("rfc-b-\(UUID().uuidString).bin")
    try Data("AAA".utf8).write(to: a)
    try Data("BBB".utf8).write(to: b)
    defer {
        try? FileManager.default.removeItem(at: a)
        try? FileManager.default.removeItem(at: b)
    }

    let request = try URLRequest {
        RequestBody.multipart(boundary: "TEST") {
            MultipartPart.file(name: "attachment", fileURL: a)
            MultipartPart.file(name: "attachment", fileURL: b)
        }
    }
    let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
    let occurrences = body.components(separatedBy: "name=\"attachment\"").count - 1
    #expect(occurrences == 2)
    #expect(body.contains("filename=\"\(a.lastPathComponent)\""))
    #expect(body.contains("filename=\"\(b.lastPathComponent)\""))
}

// MARK: - CachePolicy / NetworkServiceType / HTTPShouldHandleCookies

@Test func networkServiceTypeApplied() throws {
    let request = try URLRequest {
        RequestMutation[\.networkServiceType, .background]
    }
    #expect(request.networkServiceType == .background)
}

@Test(arguments: [true, false]) func httpShouldHandleCookiesApplied(_ flag: Bool) throws {
    let request = try URLRequest {
        RequestMutation[\.httpShouldHandleCookies, flag]
    }
    #expect(request.httpShouldHandleCookies == flag)
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

// MARK: - Networking knobs via URLRequest init

@Test func timeoutAndCachePolicyApplied() throws {
    let request = try URLRequest {
        BaseURL("https://api.example.com")
        RequestMutation[\.cachePolicy, .reloadIgnoringLocalCacheData]
        Timeout(5)
        Method.GET
    }
    #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
    #expect(request.timeoutInterval == 5)
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

// MARK: - MIMEType nodes

@Test func contentTypeBlockSetsHeader() throws {
    let request = try URLRequest {
        MIMEType.json.contentType
    }
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
}

@Test func contentTypeLastWriteWins() throws {
    let request = try URLRequest {
        MIMEType.json.contentType
        MIMEType.xml.contentType
    }
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/xml")
}

// MARK: - Accept

@Test func acceptSingleType() throws {
    let request = try URLRequest {
        MIMEType.json.accept
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
}

@Test func acceptMultipleTypesAccumulate() throws {
    let request = try URLRequest {
        MIMEType.json.accept
        MIMEType.xml.accept
        MIMEType.html.accept
    }
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json,application/xml,text/html")
}

// MARK: - Method (every standard case)

@Test func methodAppliesRawValueForAllStandardCases() throws {
    let cases: [DeclarativeRequests.Method] = [.HEAD, .PUT, .DELETE, .CONNECT, .OPTIONS, .TRACE, .PATCH, .QUERY]
    for method in cases {
        let request = try URLRequest { method }
        #expect(request.httpMethod == method.rawValue)
    }
}


// MARK: - Coverage restored after debloat

@Test func relativeEndpointResolvesAgainstBase() throws {
    let request = try URLRequest {
        Endpoint("player_api.php")
        Query("a", "1")
        BaseURL("https://api.example.com")
    }
    #expect(request.url?.absoluteString == "https://api.example.com/player_api.php?a=1")
}

@Test func basicAuthHandlesColonInPassword() throws {
    let request = try URLRequest {
        Authorization.basic(username: "alice", password: "a:b:c")
    }
    let expected = "Basic \(Data("alice:a:b:c".utf8).base64EncodedString())"
    #expect(request.value(forHTTPHeaderField: "Authorization") == expected)
}

@Test func useEncoderAppliesCustomEncoder() throws {
    struct Model: Codable { let userName: String }
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let request = try RequestBlock {
        RequestBody.json(Model(userName: "x"))
    }.useEncoder(encoder).request
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "{\"user_name\":\"x\"}")
}

@Test func cookieFromEncodable() throws {
    struct Model: Codable {
        var str1: String?
        var str2 = "2"
        var num1: Int?
        var num2 = 2
    }
    let request = try URLRequest {
        Cookie("x", "y")
        Cookie(Model())
        Cookie("1", "2")
    }
    #expect(request.value(forHTTPHeaderField: Header.cookie.rawValue) == "1=2; num2=2; str2=2; x=y")
}

@Test func mimeRawValues() {
    let pairs: [(MIMEType, String)] = [
        (.svg, "image/svg+xml"),
        (.ico, "image/vnd.microsoft.icon"),
        (.mp3, "audio/mpeg"),
        (.m4a, "audio/mp4"),
        (.mpeg, "video/mpeg"),
        (.eventStream, "text/event-stream"),
        (.formURLEncoded, "application/x-www-form-urlencoded"),
        (.jsonPatch, "application/json-patch+json"),
        (.mergePatch, "application/merge-patch+json"),
    ]
    for (mime, raw) in pairs {
        #expect(mime.rawValue == raw)
    }
}

@Test func useEncoderIsScopedToItsGroup() throws {
    struct Model: Codable { let userName: String }
    let snake = JSONEncoder()
    snake.keyEncodingStrategy = .convertToSnakeCase
    let request = try URLRequest {
        RequestBlock {
            Query(Model(userName: "a"))
        }.useEncoder(snake)
        Query(Model(userName: "b"))
    }
    #expect(request.url?.query == "user_name=a&userName=b")
}
