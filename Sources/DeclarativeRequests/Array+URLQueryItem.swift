import Foundation

extension [URLQueryItem] {
    var urlEncoded: Data? {
        var components = URLComponents()
        components.queryItems = self
        return components.percentEncodedQuery?.data(using: .utf8)
    }
}
