import AsyncHTTPClient
import Testing
import Vapor

struct ProxyMiddleware: AsyncMiddleware {
    let responser: @Sendable (Request) async throws -> Response
    func respond(to request: Request, chainingTo _: AsyncResponder) async throws -> Response {
        try await responser(request)
    }
}

actor RequestForwarder {
    init(timeoutSeconds: Int64 = 15, transform: @escaping (URI) -> URI) {
        self.transform = transform
        self.timeoutSeconds = timeoutSeconds
    }

    let transform: (URI) -> URI
    let timeoutSeconds: Int64

    func forw(request: Request) async throws -> Response {
        let forwardedURL = transform(request.url)
        var clientRequest = HTTPClientRequest(url: forwardedURL.string)
        clientRequest.method = request.method
        clientRequest.headers = request.headers
        clientRequest.headers.remove(name: "Host")
        clientRequest.body = request.body.data.map { .bytes($0) }

        // Fire the request
        let client = request.application.http.client.shared
        let backendResponse = try await client.execute(clientRequest, timeout: .seconds(timeoutSeconds))

        // Process response before returning (if needed)
        let vaporResponse = Response(status: backendResponse.status, headers: backendResponse.headers)
        let baffer = try await backendResponse.body.collect(upTo: .max)
        vaporResponse.body = .init(buffer: baffer)
        return vaporResponse
    }
}

struct GoogleForwarder {
    let app: Application
    let interceptor = VaporArchive()
    private let appStarter: ResourceCleaner

    init(midlewares: [any AsyncMiddleware]) {
        app = Application(.testing)
        app.middleware.use(VaporInterceptor(intercept: interceptor.save))
        for midle in midlewares {
            app.middleware.use(midle)
        }
        app.http.server.configuration.port = .zero
        appStarter = ResourceCleaner(app: app)
    }
}

struct TestForwarder {
    func makeForwarder(domain: String) -> RequestForwarder {
        RequestForwarder { uri in
            var res = uri
            res.host = domain
            res.port = nil
            res.scheme = "https"
            return res
        }
    }

    @Test(arguments: ["github.com"]) func googleForward(_ domain: String) async throws {
        let server = GoogleForwarder(
            midlewares: [ProxyMiddleware(responser: makeForwarder(domain: domain).forw)]
        )
        let request = URLRequest(url: server.app.baseUrl)
        let (_, response) = try await URLSession.shared.data(for: request)
        let (vaporRequest, vaporResponse, error) = await server.interceptor.get(response)
        #expect(vaporRequest.headers["Host"].first!.starts(with: "127.0.0.1"))

        if domain.isEmpty {
            #expect((error as! HTTPClientError).description == "HTTPClientError.emptyHost")
        } else {
            #expect(vaporResponse.headers.contains(name: "etag"))
        }
    }
}
