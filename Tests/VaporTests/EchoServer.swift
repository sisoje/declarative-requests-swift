import Foundation
import Vapor

struct EchoServer {
    let app: Application
    private let appLifecycler: ResourceCleaner

    struct User: Codable, Equatable, Content {
        let id: Int
        let name: String
    }

    struct Echo: Codable, Equatable, Content {
        let message: String
        let count: Int
    }

    static func make() async throws -> EchoServer {
        let app = try await Application.make(.testing)
        app.http.server.configuration.port = .zero

        app.get("ping") { _ in
            "pong"
        }

        app.get("users", ":id") { req -> User in
            let id = req.parameters.get("id", as: Int.self) ?? 0
            return User(id: id, name: "User-\(id)")
        }

        app.post("echo") { req -> Echo in
            try req.content.decode(Echo.self)
        }

        let lifecycler = ResourceCleaner(app: app)
        return EchoServer(app: app, appLifecycler: lifecycler)
    }
}
