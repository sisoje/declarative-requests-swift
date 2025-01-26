import Testing
@testable import DeclarativeRequests
import Foundation

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
