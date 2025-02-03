import Foundation
import Vapor

final class MockServer {
    private let app: Application
    var middleware: MockServerMiddleware

    init() {
        app = Application(.testing)
        middleware = MockServerMiddleware()
        app.middleware.use(middleware)
        app.http.server.configuration.port = .zero
        app.get(.catchall) { _ in "Success" }
        app.post(.catchall) { _ in "Success" }
        try! app.start()
    }

    var baseUrl: URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = app.http.server.configuration.hostname
        components.port = app.http.server.configuration.port
        return components.url!
    }

    deinit {
        app.shutdown()
    }
}

actor MockServerMiddleware: AsyncMiddleware {
    private let headerName = "X-Vapor-Test-ID"
    private var requests: [String: Request] = [:]
    private var responses: [String: Response] = [:]

    func getVaporRequest(_ response: URLResponse) -> (Request, Response) {
        let response = response as! HTTPURLResponse
        let id = response.value(forHTTPHeaderField: headerName)!
        return (requests.removeValue(forKey: id)!, responses.removeValue(forKey: id)!)
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let requestID = UUID().uuidString
        requests[requestID] = request

        let response = try await next.respond(to: request)
        responses[requestID] = response
        response.headers.add(name: headerName, value: requestID)
        return response
    }
}
