import Foundation

struct RequestBuilderState {
    var pathComponents: URLComponents = .init()
    var request: URLRequest = .init()
}
