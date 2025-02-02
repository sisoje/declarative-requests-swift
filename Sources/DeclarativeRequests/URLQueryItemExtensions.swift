import Foundation

extension Array where Element == URLQueryItem {
    init(queryItemsReflecting object: Any) {
        let dic: [String: Any] = Dictionary(reflecting: object)
        self = dic.compactMap { name, value in
            if let num = value as? NSNumber {
                return URLQueryItem(name: name, value: num.description)
            }

            if let str = value as? String? {
                return URLQueryItem(name: name, value: str)
            }

            return nil
        }
    }
}
