import DeclarativeRequestsExt
import Foundation
import Testing

@Test func concreteTypesTest() throws {
    let builder = RequestBlock {
        URL(string: "https://google.com")
        Method.GET
        "/getLanguage"
        URLQueryItem(name: "count", value: "1")
    }

    var source = RequestState()
    try builder.transformer(&source)
    #expect(source.request.url?.absoluteString == "https://google.com/getLanguage?count=1")
}

@Test func concreteTypesDataTest() throws {
    let testData: [UInt8] = [0x68, 0x65, 0x6C, 0x6C, 0x6F]

    let builder = RequestBlock {
        Data(testData)
    }

    let request = try URL(filePath: "/api/users").buildRequest {
        builder
    }

    #expect(request.httpBody == Data(testData))
}
