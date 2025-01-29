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
    let builder = RootNode {
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
    let builder = RootNode {
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

@Test func concreteTypesTest() throws {
    let builder = RootNode {
        URL(string: "https://google.com")
        Method.GET
        "/getLanguage"
        URLQueryItem(name: "count", value: "1")
    }

    var source = RequestState()
    try builder.transformer(&source)
    #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?count=1")
}

@Test func concreteTypesDataTest() throws {
    let testData: [UInt8] = [0x68, 0x65, 0x6C, 0x6C, 0x6F]

    let builder = RootNode {
        Data(testData)
    }

    let request = try URL(filePath: "/api/users").buildRequest {
        builder
    }

    #expect(request.httpBody == Data(testData))
}
