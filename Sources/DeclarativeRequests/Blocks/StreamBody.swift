import Foundation

public struct StreamBody: RequestBuildable {
    let stream: () -> InputStream?

    public init(_ str: @autoclosure @escaping () -> InputStream?) {
        stream = str
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            guard let stream = stream() else {
                throw DeclarativeRequestsError.badStream
            }
            state.request.httpBodyStream = stream
        }
    }
}
