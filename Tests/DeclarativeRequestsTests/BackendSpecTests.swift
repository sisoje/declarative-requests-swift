import DeclarativeRequests
import Foundation
import Testing

let baseURL = URL(string: "https://api.example.com/api")!

@Test func authorizedEndpoint() throws {
    let request = try UserEndpoint.getUser(id: "42")
        .authorized(token: "T")
        .base(baseURL)
        .request
    #expect(request.url?.absoluteString == "https://api.example.com/api/v1/users/42")
    #expect(request.httpMethod == "GET")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer T")
}

@Test func publicEndpointCarriesNoAuth() throws {
    let request = try UserEndpoint.refreshToken(token: "R")
        .authorized(token: nil)
        .base(baseURL)
        .request
    #expect(request.url?.absoluteString == "https://api.example.com/api/v1/auth/refresh")
    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
}

@Test func missingTokenFailsAtRequest() {
    #expect(throws: UserEndpoint.MissingToken.self) {
        try UserEndpoint.getUser(id: "42")
            .authorized(token: nil)
            .base(baseURL)
            .request
    }
}

// The README "Backend spec" example, verbatim — the spec is code, so the docs can't drift.
enum UserEndpoint {
    case getUser(id: String)
    case refreshToken(token: String)

    var needsAuth: Bool {
        switch self {
        case .getUser: true
        case .refreshToken: false
        }
    }

    @RequestBuilder var spec: some RequestBuildable {
        switch self {
        case let .getUser(id):
            Method.GET
            Endpoint("/v1/users/\(id)")
        case let .refreshToken(token):
            Method.POST
            Endpoint("/v1/auth/refresh")
            RequestBody.json(["token": token])
        }
    }

    struct MissingToken: Error {}

    func authorized(token: String?) -> some RequestBuildable {
        RequestBlock {
            spec
            if needsAuth {
                if let token {
                    Authorization.bearer(token)
                } else {
                    RequestBlock { _ in throw MissingToken() }
                }
            }
        }
    }
}

extension RequestBuildable {
    func base(_ url: URL) -> some RequestBuildable {
        RequestBlock {
            self
            BaseURL(url)
        }
    }
}
