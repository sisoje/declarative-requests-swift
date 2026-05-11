@testable import DeclarativeRequests
import Foundation
import Testing

// MARK: - MIMEType creation

@Test func mimeTypeFromRawValue() {
    let mime = MIMEType(rawValue: "application/json")
    #expect(mime.rawValue == "application/json")
}

@Test func mimeTypeFromStringLiteral() {
    let mime: MIMEType = "text/html"
    #expect(mime.rawValue == "text/html")
    #expect(mime.description == "text/html")
}

// MARK: - Parsing

@Test func essenceStripsParametersAndLowercases() {
    let mime: MIMEType = "Text/HTML; charset=utf-8"
    #expect(mime.essence == "text/html")
    #expect(mime.type == "text")
    #expect(mime.subtype == "html")
    #expect(mime.parameters == ["charset": "utf-8"])
}

@Test func parsingWithMultipleParameters() {
    let mime: MIMEType = "text/html; charset=utf-8; q=0.9"
    #expect(mime.parameters == ["charset": "utf-8", "q": "0.9"])
}

@Test func parsingWithNoSlash() {
    let mime: MIMEType = "invalid"
    #expect(mime.type == "invalid")
    #expect(mime.subtype == nil)
}

@Test func parametersKeysAreLowercased() {
    let mime: MIMEType = "text/html; Charset=utf-8"
    #expect(mime.parameters["charset"] == "utf-8")
}

// MARK: - Matching

@Test func matchesIgnoresParameters() {
    let a: MIMEType = "application/json; charset=utf-8"
    #expect(a.matches(.json))
    #expect(!MIMEType.json.matches(.xml))
}

// MARK: - Composing with parameters

@Test func withSingleParameter() {
    let mime = MIMEType.json.with(.charset(.utf8))
    #expect(mime.rawValue == "application/json; charset=utf-8")
}

@Test func withChainedParameters() {
    let mime = MIMEType.html
        .with(.charset(.utf8))
        .with(.quality(0.9))
    #expect(mime.rawValue == "text/html; charset=utf-8; q=0.9")
}

@Test func withVariadicParameters() {
    let mime = MIMEType.json.with(.charset(.utf8), .quality(1))
    #expect(mime.rawValue == "application/json; charset=utf-8; q=1")
}

@Test func withEmptyArrayReturnsOriginal() {
    let mime = MIMEType.json.with([])
    #expect(mime.rawValue == "application/json")
}

// MARK: - Namespaces (one per category)

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

@Test func multipartFormDataWithBoundary() {
    let mime = MIMEType.Multipart.formData(boundary: "----Boundary123")
    #expect(mime.rawValue == "multipart/form-data; boundary=----Boundary123")
}

@Test func fontNamespace() {
    #expect(MIMEType.Font.woff2.rawValue == "font/woff2")
}

// MARK: - Codable

@Test func mimeTypeCodableRoundtrips() throws {
    let original: MIMEType = "image/png; q=0.8"
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(MIMEType.self, from: data)
    #expect(original == decoded)
}

// MARK: - Hashable / Equatable

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

// MARK: - MIMEType.Parameter

@Test func parameterRawValue() {
    let param = MIMEType.Parameter(name: "charset", value: "utf-8")
    #expect(param.rawValue == "charset=utf-8")
}

@Test func parameterCharset() {
    let fromType = MIMEType.Parameter.charset(.utf8)
    let fromString = MIMEType.Parameter.charset("koi8-r")
    #expect(fromType.name == "charset")
    #expect(fromType.value == "utf-8")
    #expect(fromString.value == "koi8-r")
}

@Test func parameterQualityFormatsAndClamps() {
    #expect(MIMEType.Parameter.quality(1.0).value == "1")
    #expect(MIMEType.Parameter.quality(0.5).value == "0.5")
    #expect(MIMEType.Parameter.quality(0.123).value == "0.123")
    #expect(MIMEType.Parameter.quality(1.5).value == "1")
    #expect(MIMEType.Parameter.quality(-0.5).value == "0")
}

@Test func parameterBoundary() {
    let param = MIMEType.Parameter.boundary("----WebKitFormBoundary")
    #expect(param.name == "boundary")
    #expect(param.value == "----WebKitFormBoundary")
}

@Test func parameterCustom() {
    let param = MIMEType.Parameter.custom("level", "1")
    #expect(param.name == "level")
    #expect(param.value == "1")
}

@Test func parameterHashable() {
    let a = MIMEType.Parameter.charset(.utf8)
    let b = MIMEType.Parameter(name: "charset", value: "utf-8")
    #expect(a == b)
}

// MARK: - MIMEType.Charset

@Test func charsetConstants() {
    #expect(MIMEType.Charset.utf8.rawValue == "utf-8")
    #expect(MIMEType.Charset.utf16.rawValue == "utf-16")
    #expect(MIMEType.Charset.iso88591.rawValue == "iso-8859-1")
}

@Test func charsetFromStringLiteral() {
    let charset: MIMEType.Charset = "koi8-r"
    #expect(charset.rawValue == "koi8-r")
}

// MARK: - MIMEType.List

@Test func mimeTypeListFormatsCommaSeparated() {
    let list = MIMEType.List(.json, .xml)
    #expect(list.rawValue == "application/json, application/xml")
    #expect(list.description == "application/json, application/xml")
}

@Test func mimeTypeListFromArrayLiteral() {
    let list: MIMEType.List = [.json, .html, .xml]
    #expect(list.items.count == 3)
}

@Test func mimeTypeListEmpty() {
    let list = MIMEType.List([])
    #expect(list.rawValue == "")
}

@Test func mimeTypeListHashable() {
    let a: MIMEType.List = [.json, .xml]
    let b: MIMEType.List = [.json, .xml]
    #expect(a == b)
}

// MARK: - Real-world constructions

@Test func textPlainWithCharset() {
    let mime = MIMEType.Text.plain.with(.charset(.utf8))
    #expect(mime.rawValue == "text/plain; charset=utf-8")
}

@Test func acceptHeaderWithWildcards() {
    let list = MIMEType.List(
        MIMEType("text/*"),
        MIMEType.Application.json,
        MIMEType("*/*").with(.quality(0.1))
    )
    #expect(list.rawValue == "text/*, application/json, */*; q=0.1")
}

@Test func htmlWithCharsetAndQuality() {
    let mime = MIMEType.Text.html
        .with(.charset(.utf8), .quality(0.9))
    #expect(mime.rawValue == "text/html; charset=utf-8; q=0.9")
}

@Test func acceptHeaderWithWeightedTypes() {
    let list = MIMEType.List(
        MIMEType.Application.json,
        MIMEType.Application.xml.with(.quality(0.8)),
        MIMEType.Text.html.with(.quality(0.5))
    )
    #expect(list.rawValue == "application/json, application/xml; q=0.8, text/html; q=0.5")
}
