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
        try! app.server.start()
        cleanup = {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                await app.server.shutdown()
                try? await app.asyncShutdown()
                semaphore.signal()
            }
            semaphore.wait()
        }
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
    let interceptor: VaporArchive
    private let appLifecycler: ResourceCleaner

    static func make() async throws -> MockServer {
        let app = try await Application.make(.testing)
        let interceptor = VaporArchive()
        app.middleware.use(VaporInterceptor(intercept: interceptor.save))
        app.http.server.configuration.port = .zero
        let lifecycler = ResourceCleaner(app: app)
        return MockServer(app: app, interceptor: interceptor, appLifecycler: lifecycler)
    }
}

struct VaporInterceptor: AsyncMiddleware {
    let intercept: @Sendable (Request, Response, Error?) async -> Void

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        _ = try await request.body.collect(max: nil).get()

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
