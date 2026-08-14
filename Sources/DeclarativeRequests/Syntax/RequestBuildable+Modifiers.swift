import Foundation

public extension RequestBuildable {
    var request: URLRequest {
        get throws {
            let state = RequestState()
            try transform(state)
            return state.request
        }
    }

    func base(_ url: URL) -> some RequestBuildable {
        RequestBlock {
            self
            BaseURL(url)
        }
    }

    func useEncoder(_ encoder: JSONEncoder) -> some RequestBuildable {
        RequestBlock { state in
            let original = state.encoder
            defer { state.encoder = original }
            state.encoder = encoder
            try transform(state)
        }
    }
}
