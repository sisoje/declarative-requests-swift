import Foundation
import Vapor

actor VaporArchive {
    private let headerName = "X-Vapor-Test-ID"
    private var requests: [String: Request] = [:]
    private var responses: [String: Response] = [:]

    func get(_ response: URLResponse) async -> (Request, Response) {
        let response = response as! HTTPURLResponse
        let id = response.value(forHTTPHeaderField: headerName)!
        return (requests.removeValue(forKey: id)!, responses.removeValue(forKey: id)!)
    }

    func save(_ vreq: Request, _ vresp: Response) async {
        let requestID = UUID().uuidString
        requests[requestID] = vreq
        responses[requestID] = vresp
        vresp.headers.add(name: headerName, value: requestID)
    }
}

final class AppLifecycler {
    let shutdown: () -> Void

    init(app: Application) {
        try! app.start()
        shutdown = { app.shutdown() }
    }

    deinit {
        shutdown()
    }
}

struct MockServer {
    private let app: Application
    let interceptor = VaporArchive()
    private let midleware: AsyncMiddleware
    private let appLifecycler: AppLifecycler

    init() {
        app = Application(.testing)
        midleware = VaporInterceptor(intercept: interceptor.save)
        app.middleware.use(midleware)
        app.http.server.configuration.port = .zero
        app.get(.catchall) { _ in "Success" }
        app.post(.catchall) { _ in "Success" }
        appLifecycler = .init(app: app)
    }

    var baseUrl: URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = app.http.server.configuration.hostname
        components.port = app.http.server.configuration.port
        return components.url!
    }
}

struct VaporInterceptor: AsyncMiddleware {
    let intercept: @Sendable (Request, Response) async -> Void
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        await intercept(request, response)
        return response
    }
}
