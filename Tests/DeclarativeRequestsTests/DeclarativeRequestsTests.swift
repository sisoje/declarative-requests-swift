@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func testUrl() throws {
    let request = try URL(string: "https://google.com/")?.request {
        HttpMethod(method: .GET)
        Endpoint(path: "getLanguage")
        AddQueryParams(params: ["languageId": "1"])
    }
    #expect(request?.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test(arguments: [true, false]) func testVarious(_ isFirst: Bool) async throws {
    let builder = RequestBuilderGroup {
        HttpMethod(method: .GET)

        RequestBuilderGroup()

        RequestBuilderGroup {
            if isFirst {
                AddQueryParams(params: ["languageId": "1"])
            } else {
                AddQueryParams(params: ["languageId": "2"])
            }

            for _ in 1 ... 2 {
                Endpoint(path: "getLanguage")
            }
        }

        BaseURL(url: URL(string: "https://google.com")!)
    }

    let source = RequestSourceOfTruth()

    try source.state.runBuilder { builder }

    if isFirst {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?languageId=2")
    }
}
