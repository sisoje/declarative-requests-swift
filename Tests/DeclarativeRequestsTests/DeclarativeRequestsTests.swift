@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func baseUrlTest() throws {
    let baseUrl = URL(string: "https://google.com")
    let request = try baseUrl?.buildRequest {
        HTTPMethod.PATCH
        Endpoint(path: "getLanguage")
        QueryParams(params: ["languageId": "1"])
    }
    #expect(request?.httpMethod == "PATCH")
    #expect(request?.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test func bodyTest() throws {
    let request = try URL(filePath: "").buildRequest {
        JSONBody(value: [1])
    }
    let str = request.httpBody.map { String.init(data: $0, encoding: .utf8) }
    #expect(str == "[1]")
}

@Test func httpMethodTest() throws {
    let request = try URL(filePath: "").buildRequest {
        HTTPMethod.custom("sisoje")
    }
    #expect(request.httpMethod == "sisoje")
}

@Test(arguments: [true, false]) func expressionsTest(_ isFirst: Bool) async throws {
    let builder = RequestBuilderGroup {
        HTTPMethod.GET

        RequestBuilderGroup {
            if isFirst {
                QueryParams(params: ["languageId": "1"])
            } else {
                QueryParams(params: ["languageId": "2"])
            }

            for _ in 1 ... 2 {
                Endpoint(path: "getLanguage")
            }
        }

        BaseURL(url: URL(string: "https://google.com")!)
    }

    var source = RequestBuilderState()
    try builder.modify(state: &source)
    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=2")
    }
}
