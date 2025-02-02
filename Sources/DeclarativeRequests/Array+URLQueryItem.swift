import Foundation

extension [URLQueryItem] {
    var urlEncoded: Data? {
        var components = URLComponents()
        components.queryItems = self
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    init(reflecting object: Any) {
        let numbers: [String: NSNumber?] = Dictionary(reflecting: object)
        let strings: [String: String?] = Dictionary(reflecting: object)
        self = numbers.mapValues(\.?.description).map(URLQueryItem.init) + strings.map(URLQueryItem.init)
    }
}
