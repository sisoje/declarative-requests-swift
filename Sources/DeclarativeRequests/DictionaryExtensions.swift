import Foundation

extension Dictionary where Key == String {
    init(reflecting object: Any) {
        let tuples: [(String, Value)] = Mirror(reflecting: object).children
            .compactMap { child in
                guard let name = child.label, let value = child.value as? Value else { return nil }
                return (name, value)
            }
        self = Dictionary(uniqueKeysWithValues: tuples)
    }
}
