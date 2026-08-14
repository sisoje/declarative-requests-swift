import DeclarativeRequests
import Foundation
import Testing

// The README "Open Spec" example, verbatim — the spec is code, so the docs can't drift.
// the whole backend in one closed type: endpoints + security, like the
// sections of an OpenAPI document
enum BackendSpec {
    // each operation IS a block
    enum Operation: RequestBuildable {
        case getUser(id: String)
        case refreshToken(token: String)

        var body: some RequestBuildable {
            switch self {
            case let .getUser(id):
                Method.GET
                Endpoint("v1/users/\(id)")
            case let .refreshToken(token):
                Method.POST
                Endpoint("v1/auth/refresh")
                RequestBody.json(["token": token])
            }
        }
    }

    // the security section: one scheme = one factory
    enum Security {
        static func needsAuthorization(_ operation: Operation) -> Bool {
            switch operation {
            case .getUser: true
            case .refreshToken: false
            }
        }

        static func authorization(token: String) -> some RequestBuildable {
            Authorization.bearer(token)
        }
    }
}

// the client: session + environment in one place; gating is its rule
struct MissingToken: Error {}

struct APIClient {
    var baseURL: URL
    var token: String?

    func request(_ operation: BackendSpec.Operation) throws -> URLRequest {
        try RequestBlock {
            operation
            BaseURL(baseURL)
            if BackendSpec.Security.needsAuthorization(operation) {
                if let token {
                    BackendSpec.Security.authorization(token: token)
                } else {
                    RequestFailure(MissingToken())
                }
            }
        }.request()
    }
}

let client = APIClient(baseURL: URL(string: "https://api.example.com/api")!, token: "T")

@Test func wiredRequest() throws {
    let user = try client.request(.getUser(id: "42"))
    let refresh = try client.request(.refreshToken(token: "R"))

    #expect(user.url?.absoluteString == "https://api.example.com/api/v1/users/42")
    #expect(user.value(forHTTPHeaderField: "Authorization") == "Bearer T")
    #expect(refresh.url?.absoluteString == "https://api.example.com/api/v1/auth/refresh")
    #expect(refresh.value(forHTTPHeaderField: "Authorization") == nil)
}

@Test(arguments: [
    URL(string: "https://api.example.com/api")!,
    URL(string: "https://api.example.com/api/")!,
]) func authorizedEndpoint(_ baseURL: URL) throws {
    let client = APIClient(baseURL: baseURL, token: "T")
    let request = try client.request(.getUser(id: "42"))
    #expect(request.url?.absoluteString == "https://api.example.com/api/v1/users/42")
    #expect(request.httpMethod == "GET")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer T")
}

@Test(arguments: [
    URL(string: "https://api.example.com/api")!,
    URL(string: "https://api.example.com/api/")!,
]) func publicEndpointCarriesNoAuth(_ baseURL: URL) throws {
    let client = APIClient(baseURL: baseURL, token: nil)
    let request = try client.request(.refreshToken(token: "R"))
    #expect(request.url?.absoluteString == "https://api.example.com/api/v1/auth/refresh")
    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
}

@Test(arguments: [
    URL(string: "https://api.example.com/api")!,
    URL(string: "https://api.example.com/api/")!,
]) func missingTokenFailsAtRequest(_ baseURL: URL) {
    let client = APIClient(baseURL: baseURL, token: nil)
    #expect(throws: MissingToken.self) {
        try client.request(.getUser(id: "42"))
    }
}
