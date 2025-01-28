import Foundation

public struct RequestBuilderState {
    var baseURL: URL?
    var pathComponents: URLComponents = .init()
    private var _request: URLRequest = .init(url: URL(fileURLWithPath: ""))
    var request: URLRequest {
        get {
            var res = _request
            res.url = pathComponents.url(relativeTo: baseURL)
            return res
        }
        set {
            _request = newValue
        }
    }
}
