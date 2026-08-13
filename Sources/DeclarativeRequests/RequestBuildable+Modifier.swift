import Foundation

public extension RequestBuildable {
    func useEncoder(_ encoder: JSONEncoder) -> RequestStateTransformer {
        RequestStateTransformer { state in
            state.encoder = encoder
            try transform(state)
        }
    }
}
