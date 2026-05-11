import Foundation

public enum DeclarativeRequestsError: Error, Equatable, LocalizedError {
    case badUrl

    case badStream

    case badMultipart(reason: String)

    case encodingFailed(reason: String)

    public var errorDescription: String? {
        switch self {
        case .badUrl:
            "The URL is missing or could not be constructed."
        case .badStream:
            "The input stream could not be opened."
        case let .badMultipart(reason):
            "Multipart body could not be built: \(reason)"
        case let .encodingFailed(reason):
            "Encoding failed: \(reason)"
        }
    }
}
