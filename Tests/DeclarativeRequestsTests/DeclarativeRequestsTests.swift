@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func baseUrlTest() throws {
    let baseUrl = URL(string: "https://google.com")!
    let request = try baseUrl.buildRequest {
        HTTPHeader.contentType.addValue("xxx")
        HTTPMethod.POST
        JSONBody(1)
        Endpoint("getLanguage")
        QueryParams(["languageId": "1"])
    }
    #expect(request.httpBody == "1".data(using: .utf8))
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func urlRequestTest() throws {
    let request = try URLRequest {
        HTTPMethod.POST
        BaseURL("https://google.com")
        Endpoint("/getLanguage")
        HTTPBody("{}".data(using: .utf8))
        QueryParams(["languageId": "1"])
    }
    #expect(request.httpMethod == "POST")
    #expect(request.httpBody == "{}".data(using: .utf8))
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
        HTTPMethod.custom("sisoje")
    }
    #expect(request.httpMethod == "sisoje")
}

@Test(arguments: [true, false], [1, 2]) func complexRequestTest(_ isFirst: Bool, _: Int) async throws {
    let builder = RequestGroup {
        BaseURL("https://google.com")

        HTTPMethod.GET

        Endpoint("/getLanguage")

        RequestGroup {
            if isFirst {
                QueryParams(["languageId": "1"])
            } else {
                QueryParams(["languageId": "2"])
            }
        }
    }

    var source = RequestBuilderState()
    try builder.transformer(&source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=2")
    }
}
