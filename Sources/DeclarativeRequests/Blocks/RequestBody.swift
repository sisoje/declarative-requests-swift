import Foundation

public enum RequestBody {}

public extension RequestBody {
    static func data(_ data: Data, type: String? = nil) -> some RequestBuildable {
        RequestStateTransformer { state in
            state.request.httpBody = data
            if let type {
                state.request.setValue(type, forHTTPHeaderField: Header.contentType.rawValue)
            }
        }
    }

    static func string(_ string: String, type: String = "text/plain") -> some RequestBuildable {
        RequestStateTransformer { state in
            state.request.httpBody = Data(string.utf8)
            state.request.setValue(type, forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func json(_ value: any Encodable) -> some RequestBuildable {
        RequestStateTransformer { state in
            let body = try state.encoder.encode(value)
            state.request.httpBody = body
            state.request.setValue("application/json", forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func urlEncoded(_ items: [URLQueryItem]) -> some RequestBuildable {
        RequestStateTransformer { state in
            state.encodedBodyItems += items
            state.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func urlEncoded(_ encodable: any Encodable) -> some RequestBuildable {
        RequestStateTransformer { state in
            state.encodedBodyItems += try EncodableQueryItems(encodable: encodable, encoder: state.encoder).items
            state.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: Header.contentType.rawValue)
        }
    }

    static func stream(_ stream: @autoclosure @escaping () throws -> InputStream?) -> some RequestBuildable {
        RequestStateTransformer { state in
            guard let s = try stream() else {
                throw DeclarativeRequestsError.badStream
            }
            state.request.httpBodyStream = s
        }
    }
}
