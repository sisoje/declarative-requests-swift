import Foundation

public enum DeclarativeNetworkingError: Error {
    case notHttpURLResponse(URLResponse)
    case invalidStatusCode(Int)
    case noMappingProvided
}

public typealias NetworkTuple = (data: Data, response: URLResponse)
public typealias ResponseTransformer<T> = (inout ResponseState<T>) async throws -> Void

public struct ResponseState<T> {
    public init() {
        mapper = { _ in throw DeclarativeNetworkingError.noMappingProvided }
    }
    
    public init() where T == Void {
        mapper = { _ in }
    }
    public var validator: (NetworkTuple) async throws -> Void = { _ in }
    public var mapper: (NetworkTuple) async throws -> T
    public var finalCall: (NetworkTuple) async throws -> T {
        { tuple in
            try await validator(tuple)
            return try await mapper(tuple)
        }
    }
}

public protocol n {
    associatedtype T
    var transformer: ResponseTransformer<T> { get }
}

public struct RootValidator<T>: n {
    public init(transformer: @escaping ResponseTransformer<T>) {
        self.transformer = transformer
    }
    
    public let transformer: ResponseTransformer<T>
}

public protocol CompositeValidator: n {
    associatedtype Body: n
    var body: Body { get }
}

public extension CompositeValidator {
    var transformer: ResponseTransformer<Body.T> { body.transformer }
}


public struct IsHTTP<T>: CompositeValidator {
    var error = URLError(.unknown)
    public var body: some n {
        RootValidator<T> { state in
            if tuple.response is HTTPURLResponse {
                return
            }
            throw error
        }
    }
}

public struct StatusCode2xx: CompositeValidator {
    var error = URLError(.badServerResponse)
    public var body: some n {
        RootValidator { tuple in
            if let response = tuple.response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                return
            }
            throw error
        }
    }
}
    

