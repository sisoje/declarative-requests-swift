import Testing
@testable import DeclarativeRequests
import Foundation
import SwiftUI

final class RequestSourceOfTruth: Sendable {
    init(baseUrl: URL? = nil, pathComponents: URLComponents = URLComponents(), request: URLRequest = .initial) {
        self.baseUrl = baseUrl
        self.request = request
        self.pathComponents = pathComponents
    }

    let baseUrl: URL?
    nonisolated(unsafe) var pathComponents: URLComponents
    nonisolated(unsafe) var request: URLRequest
}

extension RequestSourceOfTruth {
    var state: RequestState {
        RequestState(
            baseUrl: baseUrl,
            request: Binding { self.request } set: { self.request = $0 },
            pathComponents: Binding { self.pathComponents } set: { self.pathComponents = $0 }
        )
    }
}

@Test func example() async throws {
    var getFirst = true
    
    let builder = RequestBuilderGroup {
        HttpMethod(method: .GET)
        
        if getFirst {
            AddQueryParams(params: ["tripId": "1"])
        } else {
            AddQueryParams(params: ["tripId": "2"])
        }
        
        for _ in 0...0 {
            Endpoint(path: "/getTrip")
        }
        
        CreateURL()
    }
    
    let source = RequestSourceOfTruth(baseUrl: URL(string: "https://google.com/")!)
    
    try source.state.runBuilder(builder)
    
    #expect(source.request.url?.absoluteString == "https://google.com/getTrip?tripId=1")
}
