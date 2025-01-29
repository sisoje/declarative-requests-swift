public typealias StateTransformer = (inout RequestState) throws -> Void

extension Sequence where Element == StateTransformer {
    var reduced: StateTransformer {
        reduce({ _ in }) { partialResult, closure in
            {
                try partialResult(&$0)
                try closure(&$0)
            }
        }
    }
}
