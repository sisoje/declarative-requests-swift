@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func baseUrlTest() throws {
    let baseUrl = URL(string: "https://google.com")!
    let request = try baseUrl.buildRequest {
        HTTPMethod.POST
        JSONBody(value: 1)
        Endpoint(path: "getLanguage")
        QueryParams(params: ["languageId": "1"])
    }
    #expect(request.httpBody == "1".data(using: .utf8))
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func urlRequestTest() throws {
    let request = try URLRequest {
        HTTPMethod.POST
        URL(string: "https://google.com")
        Endpoint(path: "getLanguage")
        Data("{}".utf8)
        URLQueryItem(name: "languageId", value: "1")
    }
    #expect(request.httpMethod == "POST")
    #expect(request.httpBody == "{}".data(using: .utf8))
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func jsonBodyTest() throws {
    let request = try URL(filePath: "").buildRequest {
        JSONBody(value: [1])
    }
    #expect(request.httpBody == "[1]".data(using: .utf8))
}

@Test func httpMethodTest() throws {
    let request = try URL(filePath: "").buildRequest {
        HTTPMethod.custom("sisoje")
    }
    #expect(request.httpMethod == "sisoje")
}

@Test(arguments: [true, false], [1, 2]) func complexRequestTest(_ isFirst: Bool, _ count: Int) async throws {
    let builder = RequestBuilderGroup {
        HTTPMethod.GET
        
        URL(string: "https://google.com")

        RequestBuilderGroup {
            if isFirst {
                [URLQueryItem(name: "languageId", value: "1")]
                 
            } else {
                [URLQueryItem(name: "languageId", value: "2")]
            }

            for _ in 1 ... count {
                "/getLanguage"
            }
        }
    }

    var source = RequestBuilderState()
    try builder.modify(state: &source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=2")
    }
}
