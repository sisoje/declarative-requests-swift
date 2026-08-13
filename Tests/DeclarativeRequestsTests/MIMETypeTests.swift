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

@Test func convenienceConstantsAliasNamespaces() {
    #expect(MIMEType.json == MIMEType.Application.json)
    #expect(MIMEType.html == MIMEType.Text.html)
    #expect(MIMEType.png == MIMEType.Image.png)
}

@Test func applicationNamespace() {
    #expect(MIMEType.Application.json.rawValue == "application/json")
}

@Test func textNamespace() {
    #expect(MIMEType.Text.eventStream.rawValue == "text/event-stream")
}

@Test func imageNamespace() {
    #expect(MIMEType.Image.svg.rawValue == "image/svg+xml")
}

@Test func audioNamespace() {
    #expect(MIMEType.Audio.opus.rawValue == "audio/opus")
}

@Test func videoNamespace() {
    #expect(MIMEType.Video.quicktime.rawValue == "video/quicktime")
}

@Test func multipartNamespace() {
    #expect(MIMEType.Multipart.formData.rawValue == "multipart/form-data")
}

@Test func fontNamespace() {
    #expect(MIMEType.Font.woff2.rawValue == "font/woff2")
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
