import Foundation

/// Appends one or more query items to the request URL.
///
/// `Query` mirrors the shape of ``URLEncodedBody`` and ``Headers``: you can
/// declare a single name/value pair or pass an `Encodable` model that flattens
/// to a list of items.
///
/// ```swift
/// // Single item:
/// Query("page", "2")
///
/// // Multiple items via repeated declarations:
/// Query("filter", "active")
/// Query("filter", "new")
///
/// // From an Encodable model:
/// struct UsersFilter: Codable { let page: Int; let pageSize: Int }
/// Query(UsersFilter(page: 2, pageSize: 50))
/// ```
///
/// Items are appended (not deduplicated), so multiple declarations with the
/// same name produce multiple `?name=…&name=…` entries. Encodable models are
/// serialized with the request's ``RequestState/encoder`` and then flattened via
/// `JSONSerialization`; nested arrays are represented with bracket-indexed
/// keys (`tags[0]=a&tags[1]=b`).
public struct Query: RequestBuildable {
    /// Append a single query item.
    ///
    /// - Parameters:
    ///   - name: The query item name.
    ///   - value: The query item value, or `nil` to emit `?name`.
    public init(_ name: String, _ value: String?) {
        items = { _ in [URLQueryItem(name: name, value: value)] }
    }

    /// Append items derived from an `Encodable` model.
    ///
    /// Top-level fields become query item names. Nested arrays produce
    /// bracket-indexed keys; nested dictionaries are flattened with their
    /// nested keys becoming the names. Booleans serialize as `"true"`/`"false"`.
    ///
    /// - Parameter encodable: The model to encode.
    public init(_ encodable: any Encodable) {
        items = {
            try EncodableQueryItems(encodable: encodable, encoder: $0).items
        }
    }

    let items: (JSONEncoder) throws -> [URLQueryItem]

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.queryItems += try items(state.encoder)
        }
    }
}
