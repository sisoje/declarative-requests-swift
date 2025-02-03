import Foundation
import Vapor

actor MockServer {
    private let app: Application
    private var middleware: MockServerMiddleware

    init() {
        app = Application(.testing)
        middleware = MockServerMiddleware()
        app.middleware.use(middleware)
        app.http.server.configuration.port = .zero
        app.get(.catchall, use: requestHandler)
        app.post(.catchall, use: requestHandler)
        try! app.start()
    }

    var baseUrl: URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = app.http.server.configuration.hostname
        components.port = app.http.server.configuration.port
        return components.url!
    }

    func getVaporRequest(_ response: URLResponse) -> Request {
        middleware.getVaporRequest(response)
    }

    private func requestHandler(_: Request) async -> String {
        "Success"
    }

    deinit {
        app.shutdown()
    }
}

private class MockServerMiddleware: Middleware, @unchecked Sendable {
    init() {}

    private let headerName = "X-Vapor-Test-ID"
    private var requests: [String: Request] = [:]

    func getVaporRequest(_ response: URLResponse) -> Request {
        let id = (response as! HTTPURLResponse).value(forHTTPHeaderField: headerName)!
        return requests.removeValue(forKey: id)!
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let testId = UUID().uuidString
        requests[testId] = request

        return next.respond(to: request).map { response in
            response.headers.add(name: self.headerName, value: testId)
            return response
        }
    }
}
