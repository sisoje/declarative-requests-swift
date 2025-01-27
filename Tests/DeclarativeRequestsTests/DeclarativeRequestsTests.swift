@testable import DeclarativeRequests
import Foundation
import SwiftUI
import Testing

@Test func testUrl() throws {
    let request = try URL(string: "https://google.com/")?.build {
        RequestBuilderGroup {
            HttpMethod(method: .GET)
            Endpoint(path: "/getTrip")
            AddQueryParams(params: ["tripId": "1"])
        }
    }
    #expect(request?.url?.absoluteString == "https://google.com/getTrip?tripId=1")
}

@Test func testSomething() async throws {
    let getFirst = true

    let builder = RequestBuilderGroup {
        HttpMethod(method: .GET)

        RequestBuilderGroup()

        RequestBuilderGroup {
            if getFirst {
                AddQueryParams(params: ["tripId": "1"])
            } else {
                AddQueryParams(params: ["tripId": "2"])
            }

            for _ in 0 ... 0 {
                Endpoint(path: "/getTrip")
            }
        }

        BaseURL(url: URL(string: "https://google.com/")!)
    }

    let source = RequestSourceOfTruth()

    try source.state.runBuilder { builder }

    #expect(source.request.url?.absoluteString == "https://google.com/getTrip?tripId=1")
}
