import DeclarativeRequests
import Foundation
import Testing

@Test(arguments: [true, false]) func disallow(_ isAllowed: Bool) throws {
    let req = try URLRequest {
        if !isAllowed {
            NetworkAccess.NoCellular
            NetworkAccess.NoConstrained
            NetworkAccess.NoExpensive
        }
    }
    #expect(req.allowsCellularAccess == isAllowed)
    #expect(req.allowsExpensiveNetworkAccess == isAllowed)
    #expect(req.allowsConstrainedNetworkAccess == isAllowed)
}

@Test func baseUrlTest() throws {
    let baseUrl = URL(string: "https://google.com")!
    let request = try baseUrl.buildRequest {
        Method.POST
        JSONBody([1])
    }
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "[1]")
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://google.com")
}

@Test func urlRequestTest() throws {
    let request = try URLRequest {
        Method.POST
        URL(string: "https://google.com")
        Endpoint("/getLanguage")
        JSONBody([1])
        Query("languageId", "1")
    }
    #expect(request.httpMethod == "POST")
    #expect(request.httpBody.map { String(decoding: $0, as: UTF8.self) } == "[1]")
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func jsonBodyTest() throws {
    let request = try URL(filePath: "").buildRequest {
        JSONBody([1])
    }
    #expect(request.httpBody == "[1]".data(using: .utf8))
}

@Test func httpMethodTest() throws {
    let request = try URL(filePath: "").buildRequest {
        Method.custom("sisoje")
    }
    #expect(request.httpMethod == "sisoje")
}

@Test(arguments: [1, 2]) func countTest(count: Int) async throws {
    let builder = RequestBlock {
        URL(string: "https://google.com")

        for i in 1 ... count {
            Endpoint("/getLanguage")
            Query("count", "\(i)")
        }
    }

    var source = RequestState()
    try builder.transformer(&source)
    if count == 1 {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?count=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?count=1&count=2")
    }
}

@Test(arguments: [true, false]) func ifWithoutElse(isFirst: Bool) async throws {
    let builder = RequestBlock {
        URL(string: "https://google.com")

        if isFirst {
            Endpoint("/first")
            Query("isFirst", "1")
        }
    }

    var source = RequestState()
    try builder.transformer(&source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/first?isFirst=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com")
    }
}

@Test(arguments: [true, false]) func ifWithElse(isFirst: Bool) async throws {
    let builder = RequestBlock {
        URL(string: "https://google.com")

        if isFirst {
            Endpoint("/first")
            Query("isFirst", "1")
        } else {
            Endpoint("/second")
        }
    }

    var source = RequestState()
    try builder.transformer(&source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/first?isFirst=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/second")
    }
}

@Test func uRLEncodedBodySingleKeyValue() async throws {
    let builder = RequestBlock {
        URLEncodedBody("key", "value")
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 1)
    #expect(items[0].name == "key")
    #expect(items[0].value == "value")
}

@Test func uRLEncodedBodyArrayOfTuplesWithDuplicates() async throws {
    let builder = RequestBlock {
        URLEncodedBody([
            ("color", "red"),
            ("color", "blue"),
            ("size", "large"),
        ])
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 3)
    #expect(items.filter { $0.name == "color" }.count == 2)
    #expect(items.contains(where: { $0.name == "color" && $0.value == "red" }))
    #expect(items.contains(where: { $0.name == "color" && $0.value == "blue" }))
    #expect(items.contains(where: { $0.name == "size" && $0.value == "large" }))
}

@Test func uRLEncodedBodyDictionary() async throws {
    let builder = RequestBlock {
        URLEncodedBody(["name": "john", "age": "25"])
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 2)
    #expect(items.contains(where: { $0.name == "name" && $0.value == "john" }))
    #expect(items.contains(where: { $0.name == "age" && $0.value == "25" }))
}

@Test func uRLEncodedBodyURLQueryItems() async throws {
    let builder = RequestBlock {
        URLEncodedBody([
            URLQueryItem(name: "tag", value: "swift"),
            URLQueryItem(name: "tag", value: "ios"),
        ])
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 2)
    #expect(items.filter { $0.name == "tag" }.count == 2)
    #expect(items.contains(where: { $0.name == "tag" && $0.value == "swift" }))
    #expect(items.contains(where: { $0.name == "tag" && $0.value == "ios" }))
}

@Test func uRLEncodedBodyEncodable() async throws {
    struct User {
        let id: Int
        let name: String
    }
    let builder = RequestBlock {
        URLEncodedBody(object: User(id: 123, name: "john"))
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 2)
    #expect(items.contains(where: { $0.name == "id" && $0.value == "123" }))
    #expect(items.contains(where: { $0.name == "name" && $0.value == "john" }))
}

@Test func uRLEncodedBodyMultipleBodiesMerging() async throws {
    let builder = RequestBlock {
        URLEncodedBody("page", "1")
        URLEncodedBody(["sort": "desc"])
        URLEncodedBody([("filter", "active"), ("filter", "new")])
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 4)
    #expect(items.contains(where: { $0.name == "page" && $0.value == "1" }))
    #expect(items.contains(where: { $0.name == "sort" && $0.value == "desc" }))
    #expect(items.filter { $0.name == "filter" }.count == 2)
    #expect(items.contains(where: { $0.name == "filter" && $0.value == "active" }))
    #expect(items.contains(where: { $0.name == "filter" && $0.value == "new" }))
}

@Test func uRLEncodedBodySequentialDuplicates() async throws {
    let builder = RequestBlock {
        for i in 1 ... 6 {
            URLEncodedBody("count", "\(i)")
        }
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []

    #expect(items.count == 6)
    #expect(items.filter { $0.name == "count" }.count == 6)
    for i in 1 ... 6 {
        #expect(items.contains(where: { $0.name == "count" && $0.value == "\(i)" }))
    }
}

@Test func queryEncodable() async throws {
    struct User {
        let id: Int
        let name: String
    }
    let builder = RequestBlock {
        Query(object: User(id: 123, name: "john"))
    }
    var source = RequestState()
    try builder.transformer(&source)
    let queryItems = source.pathComponents.queryItems ?? []

    #expect(queryItems.contains(where: { $0.name == "id" && $0.value == "123" }))
    #expect(queryItems.contains(where: { $0.name == "name" && $0.value == "john" }))
    #expect(queryItems.count == 2)
}

@Test func repositoryExample() throws {
    struct Repository {
        @RequestBuilder var refreshToken: (_ accessToken: String) -> BuilderNode
        @RequestBuilder var getUser: (String) -> BuilderNode
    }
    let repository = Repository(
        refreshToken: { accessToken in
            Method.POST
            Endpoint("/refreshToken")
            JSONBody(["token": accessToken])
        },
        getUser: { userId in
            Method.GET
            Endpoint("/user")
            Query("userId", userId)
        }
    )
    let request = try URLRequest { repository.getUser("1") }
    #expect(request.url?.absoluteString == "/user?userId=1")
    #expect(request.httpMethod == "GET")
    let request2 = try URLRequest { repository.refreshToken("1") }
    #expect(request2.url?.absoluteString == "/refreshToken")
    #expect(request2.httpMethod == "POST")
    #expect(request2.httpBody.map { String(decoding: $0, as: UTF8.self) } == "{\"token\":\"1\"}")
}

@Test func stream() throws {
    let data = Data("sisoje".utf8)
    let request = try URLRequest {
        InputStream(data: data)
    }
    #expect(request.httpBodyStream != nil)
    request.httpBodyStream?.open()
    var buffer: [UInt8] = .init(repeating: 0, count: data.count)
    request.httpBodyStream?.read(&buffer, maxLength: buffer.count)
    #expect(Data(buffer) == data)
}

@Test func query() throws {
    struct Model {
        var str1: String?
        var str2 = "2"
        var num1: Int?
        var num2 = 2
    }
    let request = try URLRequest {
        Query("x", "y")
        Query(object: Model())
        Query("1", "2")
    }
    #expect(request.url?.absoluteString == "?1=2&num2=2&str2=2&x=y")
}

@Test func cookie() throws {
    struct Model {
        var str1: String?
        var str2 = "2"
        var num1: Int?
        var num2 = 2
    }
    let request = try URLRequest {
        Cookie("x", "y")
        Cookie(object: Model())
        Cookie("1", "2")
    }
    #expect(request.value(forHTTPHeaderField: Header.cookie.rawValue) == "1=2; num2=2; str2=2; x=y")
}
