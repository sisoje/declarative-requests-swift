@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func testUrl() throws {
    let request = try URL(string: "https://google.com/")?.request {
        HTTPMethod.GET
        Endpoint(path: "getLanguage")
        QueryParams(params: ["languageId": "1"])
    }
    #expect(request?.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}

@Test(arguments: [true, false]) func testVarious(_ isFirst: Bool) async throws {
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
    let res = source.request.url?.absoluteString
    if isFirst {
        #expect(res == "https://google.com/getLanguage?languageId=1")
    } else {
        #expect(res == "https://google.com/getLanguage?languageId=2")
    }
}
