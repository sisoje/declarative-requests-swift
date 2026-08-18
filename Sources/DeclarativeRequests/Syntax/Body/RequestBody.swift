import Foundation

public enum RequestBody {}

public extension RequestBody {
    static func string(_ string: String, type: String = MIMEType.plainText.rawValue) -> some RequestBuildable {
        RequestBlock { state in
            state.request.httpBody = Data(string.utf8)
            state.request.setValue(type, forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func json(_ value: any Encodable & Sendable) -> some RequestBuildable {
        RequestBlock { state in
            let body = try state.encoder.encode(value)
            state.request.httpBody = body
            state.request.setValue(MIMEType.json.rawValue, forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func urlEncoded(_ name: String, _ value: (some LosslessStringConvertible & Sendable)?) -> some RequestBuildable {
        RequestBlock { state in
            state.encodedBodyItems += [URLQueryItem(name: name, value: value?.description)]
            state.request.setValue(MIMEType.formURLEncoded.rawValue, forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func urlEncoded(_ encodable: any Encodable & Sendable) -> some RequestBuildable {
        RequestBlock { state in
            state.encodedBodyItems += try EncodableQueryItems(encodable: encodable, encoder: state.encoder).items
            state.request.setValue(MIMEType.formURLEncoded.rawValue, forHTTPHeaderField: Header.contentType.rawValue)
        }
    }
}
