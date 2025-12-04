import Foundation

public struct StreamBody: RequestBuildable {
    let stream: () throws -> InputStream?

    public init(_ str: @autoclosure @escaping () throws -> InputStream?) {
        stream = str
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            guard let stream = try stream() else {
                throw DeclarativeRequestsError.badStream
            }
            state.request.httpBodyStream = stream
        }
    }
}
