@testable import DeclarativeRequests
import Foundation
import Testing

@Test func mimeTypeFromRawValue() {
    let mime = MIMEType(rawValue: "application/json")
    #expect(mime.rawValue == "application/json")
}

@Test func mimeTypeFromStringLiteral() {
    let mime: MIMEType = "text/html"
    #expect(mime.rawValue == "text/html")
}

@Test func flatConstants() {
    #expect(MIMEType.json.rawValue == "application/json")
    #expect(MIMEType.formURLEncoded.rawValue == "application/x-www-form-urlencoded")
    #expect(MIMEType.png.rawValue == "image/png")
}

@Test func equalityComparesRawValue() {
    let a: MIMEType = "text/html; charset=utf-8"
    let b: MIMEType = "text/html"
    #expect(a != b)
    #expect(MIMEType("application/json") == MIMEType.json)
}

@Test func hashableWorksInSet() {
    let set: Set<MIMEType> = [.json, .xml, .json]
    #expect(set.count == 2)
}
