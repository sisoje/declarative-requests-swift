import Foundation

public extension RequestBuildable {
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
