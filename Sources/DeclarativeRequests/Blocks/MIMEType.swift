import Foundation

public enum MIMEType: String {
    case json = "application/json"
    case xml = "application/xml"
    case html = "text/html"
    case plainText = "text/plain"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case octetStream = "application/octet-stream"
    case png = "image/png"
    case jpeg = "image/jpeg"
}

public extension MIMEType {
    var accept: some RequestBuildable {
        Header.accept.addValue(rawValue)
    }

    var contentType: some RequestBuildable {
        Header.contentType.setValue(rawValue)
    }
}
