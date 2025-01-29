import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func baseUrlTest() throws {
    let baseUrl = URL(string: "https://google.com")!
    let request = try baseUrl.buildRequest {
        Header.contentType.addValue("xxx")
        Method.POST
        JSONBody([1])
        Endpoint("getLanguage")
        Query("languageId", "1")
    }
    #expect(request.httpBody == "[1]".data(using: .utf8))
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func urlRequestTest() throws {
    let request = try URLRequest {
        Method.POST
        BaseURL("https://google.com")
        Endpoint("/getLanguage")
        RequestState[\.request.httpBody, Data()]
        Query("languageId", "1")
    }
    #expect(request.httpMethod == "POST")
    #expect(request.httpBody == Data())
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

@Test(arguments: [true, false], [1, 2]) func complexRequestTest(_ isFirst: Bool, _: Int) async throws {
    let builder = RootNode {
        BaseURL("https://google.com")

        Method.GET

        Endpoint("/getLanguage")

        RootNode {
            if isFirst {
                Query(["languageId": "1"])
            } else {
                Query(["languageId": "2"])
            }
        }
    }

    var source = RequestState()
    try builder.transformer(&source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=2")
    }
}
