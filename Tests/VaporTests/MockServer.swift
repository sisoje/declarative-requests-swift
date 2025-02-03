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

    func getVaporRequest(_ response: URLResponse) async -> Request {
        let httpResponse = response as! HTTPURLResponse
        return await middleware.getVaporRequest(httpResponse)
    }

    private func requestHandler(_: Request) async -> String {
        "Success"
    }

    deinit {
        app.shutdown()
    }
}

private actor MockServerMiddleware: AsyncMiddleware {
    private let headerName = "X-Vapor-Test-ID"
    private var requests: [String: Request] = [:]

    func getVaporRequest(_ response: HTTPURLResponse) async -> Request {
        let id = response.value(forHTTPHeaderField: headerName)!
        return requests.removeValue(forKey: id)!
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let testId = UUID().uuidString
        requests[testId] = request

        let response = try await next.respond(to: request)
        response.headers.add(name: headerName, value: testId)
        return response
    }
}
