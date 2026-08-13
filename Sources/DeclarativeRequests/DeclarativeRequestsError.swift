import Foundation

public enum DeclarativeRequestsError: Error, Equatable {
    case badUrl
    case badStream
    case badMultipart(reason: String)
}
