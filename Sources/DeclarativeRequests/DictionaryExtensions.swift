import Foundation

extension [String: String] {
    init(describingProperties object: Any) {
        let tuples: [(String, Value)] = Mirror(reflecting: object).children
            .compactMap { child in
                guard let name = child.label, let value = child.value as? CustomStringConvertible else {
                    return nil
                }
                return (name, value.description)
            }
        self = Dictionary(uniqueKeysWithValues: tuples)
    }
}
