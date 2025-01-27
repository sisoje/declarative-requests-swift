typealias RequestTransformer = (inout RequestBuilderState) throws -> Void

extension Array where Element == RequestTransformer {
    var reduced: RequestTransformer {
        reduce(RequestTransformerUtils.nop) { partialResult, closure in
            {
                try partialResult(&$0)
                try closure(&$0)
            }
        }
    }
}

enum RequestTransformerUtils {
    static var nop: RequestTransformer { { _ in } }
    static func merge(_ transformers: RequestTransformer...) -> RequestTransformer {
        transformers.reduced
    }
}
