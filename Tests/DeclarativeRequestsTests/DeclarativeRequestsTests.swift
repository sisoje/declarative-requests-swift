import Testing
@testable import DeclarativeRequests
import Foundation

@Test func example() async throws {
    let builder = RequestBuilderGroup {
        HttpMethod(method: .GET)
        AddQueryParams(params: ["tripId": "1"])
        Endpoint(path: "/getTrip")
        CreateURL()
    }
    
    let source = RequestSourceOfTruth(baseUrl: URL(string: "https://google.com/")!)
    
    try source.state.runBuilder(builder)
    
    #expect(source.request.url?.absoluteString == "https://google.com/getTrip?tripId=1")
}
