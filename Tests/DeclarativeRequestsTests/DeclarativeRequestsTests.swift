import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

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
        BaseURL("https://google.com")
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
        BaseURL("https://google.com")

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

@Test(arguments: [true, false]) func flagTest(isFirst: Bool) async throws {
    let builder = RequestBlock {
        BaseURL("https://google.com")

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

@Test func testURLEncodedBodySingleKeyValue() async throws {
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

@Test func testURLEncodedBodyArrayOfTuplesWithDuplicates() async throws {
    let builder = RequestBlock {
        URLEncodedBody([
            ("color", "red"),
            ("color", "blue"),
            ("size", "large")
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

@Test func testURLEncodedBodyDictionary() async throws {
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

@Test func testURLEncodedBodyURLQueryItems() async throws {
    let builder = RequestBlock {
        URLEncodedBody([
            URLQueryItem(name: "tag", value: "swift"),
            URLQueryItem(name: "tag", value: "ios")
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

@Test func testURLEncodedBodyEncodable() async throws {
    struct User: Encodable {
        let id: Int
        let name: String
    }
    let builder = RequestBlock {
        URLEncodedBody(User(id: 123, name: "john"))
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []
    
    #expect(items.count == 2)
    #expect(items.contains(where: { $0.name == "id" && $0.value == "123" }))
    #expect(items.contains(where: { $0.name == "name" && $0.value == "john" }))
}

@Test func testURLEncodedBodyMultipleBodiesMerging() async throws {
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

@Test func testURLEncodedBodySequentialDuplicates() async throws {
    let builder = RequestBlock {
        for i in 1...6 {
            URLEncodedBody("count", "\(i)")
        }
    }
    var source = RequestState()
    try builder.transformer(&source)
    let body = source.request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    let items = URLComponents(string: "?" + body)?.queryItems ?? []
    
    #expect(items.count == 6)
    #expect(items.filter { $0.name == "count" }.count == 6)
    for i in 1...6 {
        #expect(items.contains(where: { $0.name == "count" && $0.value == "\(i)" }))
    }
}

@Test func testQueryEncodable() async throws {
    struct User: Encodable {
        let id: Int
        let name: String
    }
    let builder = RequestBlock {
        Query(User(id: 123, name: "john"))
    }
    var source = RequestState()
    try builder.transformer(&source)
    let queryItems = source.pathComponents.queryItems ?? []
    
    #expect(queryItems.contains(where: { $0.name == "id" && $0.value == "123" }))
    #expect(queryItems.contains(where: { $0.name == "name" && $0.value == "john" }))
    #expect(queryItems.count == 2)
}
