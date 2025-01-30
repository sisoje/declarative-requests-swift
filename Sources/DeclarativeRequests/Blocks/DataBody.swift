import Foundation

public struct DataBody: CompositeNode {
    private let data: Data
    
    public var body: some BuilderNode {
        RequestBlock { state in
            state.request.httpBody = data
        }
    }
}
