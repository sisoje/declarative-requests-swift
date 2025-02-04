import Foundation
import Vapor

actor VaporArchive {
    private let headerName = "X-Vapor-Test-ID"
    private var requests: [String: (Request, Response, Error?)] = [:]

    func get(_ response: URLResponse) async -> (Request, Response, Error?) {
        let response = response as! HTTPURLResponse
        let id = response.value(forHTTPHeaderField: headerName)!
        return requests.removeValue(forKey: id)!
    }

    func save(_ vreq: Request, _ vresp: Response, _ error: Error?) async {
        let requestID = UUID().uuidString
        requests[requestID] = (vreq, vresp, error)
        vresp.headers.add(name: headerName, value: requestID)
    }
}

final class ResourceCleaner {
    let cleanup: () -> Void

    init(app: Application) {
        try! app.start()
        cleanup = app.shutdown
    }

    deinit {
        cleanup()
    }
}

extension Application {
    var baseUrl: URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = http.server.configuration.hostname
        components.port = http.server.configuration.port
        return components.url!
    }
}

struct MockServer {
    let app: Application
    let interceptor = VaporArchive()
    private let midleware: AsyncMiddleware
    private let appLifecycler: ResourceCleaner

    init() {
        app = Application(.testing)
        midleware = VaporInterceptor(intercept: interceptor.save)
        app.middleware.use(midleware)
        app.http.server.configuration.port = .zero
        appLifecycler = ResourceCleaner(app: app)
    }
}

struct VaporInterceptor: AsyncMiddleware {
    let intercept: @Sendable (Request, Response, Error?) async -> Void

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response: Response
        do {
            response = try await next.respond(to: request)
            await intercept(request, response, nil)
        } catch {
            response = Response(status: .internalServerError)
            await intercept(request, response, error)
        }
        return response
    }
}
