import Foundation

/// Adds form-encoded items to the request body and sets
/// `Content-Type: application/x-www-form-urlencoded`.
///
/// `URLEncodedBody` mirrors ``Query`` but writes its output into the body
/// instead of the URL. Multiple declarations with the same name accumulate as
/// repeated `name=value&name=value` pairs:
///
/// ```swift
/// // Single pair:
/// URLEncodedBody("grant_type", "password")
///
/// // From an Encodable model:
/// struct LoginForm: Codable { let grantType: String; let username: String; let password: String }
/// URLEncodedBody(LoginForm(grantType: "password", username: u, password: p))
/// ```
///
/// Encodable models go through `JSONSerialization` first; nested arrays use
/// bracket-indexed keys (`tags[0]=a&tags[1]=b`).
public struct URLEncodedBody: RequestBuildable, Sendable {
    /// Append a single form item.
    ///
    /// - Parameters:
    ///   - name: The form field name.
    ///   - value: The form field value, or `nil` to emit `&name`.
    public init(_ name: String, _ value: String?) {
        items = { _ in [URLQueryItem(name: name, value: value)] }
    }

    /// Append form items derived from an `Encodable` model.
    ///
    /// - Parameter encodable: The model to encode.
    public init(_ encodable: any Encodable & Sendable) {
        items = {
            try EncodableQueryItems(encodable: encodable, encoder: $0).items
        }
    }

    let items: @Sendable (JSONEncoder) throws -> [URLQueryItem]

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.encodedBodyItems += try items(state.encoder)
        }
        ContentType.URLEncoded
    }
}
