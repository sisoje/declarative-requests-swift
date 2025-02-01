import Foundation
import Vapor

actor MockServer {
    private let vaporRequestHeader = "X-Vapor-Test-ID"
    private let app: Application
    private var vaporRequests: [String: Request] = [:]

    init() {
        app = Application(.testing)
        app.http.server.configuration.port = .zero
        app.get(.catchall, use: requestHandler)
        app.post(.catchall, use: requestHandler)
        try! app.start()
    }

    func getVaporRequest(_ response: URLResponse) -> Request {
        let id = (response as! HTTPURLResponse).value(forHTTPHeaderField: vaporRequestHeader)!
        return vaporRequests.removeValue(forKey: id)!
    }

    var baseUrl: URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = app.http.server.configuration.hostname
        components.port = app.http.server.configuration.port
        return components.url!
    }

    private func requestHandler(_ req: Request) async -> Response {
        let testId = UUID().uuidString
        vaporRequests[testId] = req
        return Response(
            status: .ok,
            version: .http1_1,
            headers: [vaporRequestHeader: testId],
            body: "Success"
        )
    }

    deinit {
        app.shutdown()
    }
}
