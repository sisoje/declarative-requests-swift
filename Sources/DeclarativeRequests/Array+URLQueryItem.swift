import Foundation

extension [URLQueryItem] {
    var urlEncoded: Data? {
        var components = URLComponents()
        components.queryItems = self
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    init(describingProperties object: Any) {
        self = Dictionary(describingProperties: object).map(URLQueryItem.init)
    }
}
