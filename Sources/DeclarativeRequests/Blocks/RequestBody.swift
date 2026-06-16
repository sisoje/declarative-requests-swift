import Foundation

public enum RequestBody {}

public extension RequestBody {
    static func data(_ data: Data, type: MIMEType? = nil) -> some RequestBuildable {
        RequestBlock { state in
            state.request.httpBody = data
            if let type {
                state.header(Header.contentType.rawValue).value = type.rawValue
            }
        }
    }

    static func string(_ string: String, type: MIMEType = .plainText) -> some RequestBuildable {
        RequestBlock { state in
            state.request.httpBody = Data(string.utf8)
            state.header(Header.contentType.rawValue).value = type.rawValue
        }
    }

    static func json(_ value: any Encodable) -> some RequestBuildable {
        RequestBlock { state in
            let body = try state.encoder.encode(value)
            state.request.httpBody = body
            state.header(Header.contentType.rawValue).value = MIMEType.json.rawValue
        }
    }

    static func urlEncoded(_ items: [URLQueryItem]) -> some RequestBuildable {
        RequestBlock { state in
            var components = URLComponents()
            components.queryItems = items
            state.request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
            state.header(Header.contentType.rawValue).value = MIMEType.formURLEncoded.rawValue
        }
    }

    static func urlEncoded(_ encodable: any Encodable) -> some RequestBuildable {
        RequestBlock { state in
            let items = try EncodableQueryItems(encodable: encodable, encoder: state.encoder).items
            var components = URLComponents()
            components.queryItems = items
            state.request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
            state.header(Header.contentType.rawValue).value = MIMEType.formURLEncoded.rawValue
        }
    }

    static func stream(_ stream: @autoclosure @escaping () throws -> InputStream?) -> some RequestBuildable {
        RequestBlock { state in
            guard let s = try stream() else {
                throw DeclarativeRequestsError.badStream
            }
            state.request.httpBodyStream = s
        }
    }
}
