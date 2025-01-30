import Foundation

import Foundation

public struct DataBody: CompositeNode {
    public init(_ value: Data) {
        data = value
    }
    
    private let data: Data
    
    public var body: some BuilderNode {
        RequestBlock { state in
            state.request.httpBody = data
        }
    }
}
