import Foundation

public struct BaseURL: RequestBuilderModifyNode {
    public init(_ url: URL?) {
        self.url = url
    }

    public init(_ string: String) {
        url = URL(string: string)
    }

    let url: URL?
    func modify(state: inout RequestBuilderState) {
        state.baseURL = url
    }
}
