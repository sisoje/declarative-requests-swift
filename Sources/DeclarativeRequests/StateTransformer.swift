public typealias StateTransformer = (inout RequestBuilderState) throws -> Void

extension Array where Element == StateTransformer {
    var reduced: StateTransformer {
        reduce(RequestTransformerUtils.nop) { partialResult, closure in
            {
                try partialResult(&$0)
                try closure(&$0)
            }
        }
    }
}

enum RequestTransformerUtils {
    static var nop: StateTransformer { { _ in } }
    static func merge(_ transformers: StateTransformer...) -> StateTransformer {
        transformers.reduced
    }
}
