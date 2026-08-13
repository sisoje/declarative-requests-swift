import Foundation

public extension RequestBuildable {
    func useEncoder(_ encoder: JSONEncoder) -> RequestBlock {
        RequestBlock { state in
            let original = state.encoder
            defer { state.encoder = original }
            state.encoder = encoder
            try transform(state)
        }
    }
}
