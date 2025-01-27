@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func testUrl() async throws {
    let request = try await URL(string: "https://google.com/")?.request {
        HttpMethod(.GET)
        Endpoint(path: "getLanguage")
        QueryParams(params: ["languageId": "1"])
    }
    #expect(request?.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test(arguments: [true, false]) func testVarious(_ isFirst: Bool) async throws {
    let builder = RequestBuilderGroup {
        HttpMethod(.GET)

        RequestBuilderGroup()

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

    let source = RequestSourceOfTruth()

    try await builder.modify(state: source.state)
    let request = await source.request

    if isFirst {
        #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(request.url?.absoluteString == "https://google.com/getLanguage?languageId=2")
    }
}
