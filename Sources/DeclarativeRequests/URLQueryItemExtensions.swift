import Foundation

extension Array where Element == URLQueryItem {
    init(queryItemsReflecting object: Any) {
        self = Mirror(reflecting: object).children
            .compactMap { child in
                guard let name = child.label else { return nil }

                if let num = child.value as? NSNumber {
                    return URLQueryItem(name: name, value: num.description)
                }

                if let str = child.value as? String {
                    return URLQueryItem(name: name, value: str)
                }

                return nil
            }
    }
}
