public typealias RequestTransformationClosure = (inout RequestState) throws -> Void

extension Sequence where Element == RequestTransformationClosure {
    var reduced: RequestTransformationClosure {
        reduce({ _ in }) { partialResult, closure in
            {
                try partialResult(&$0)
                try closure(&$0)
            }
        }
    }
}
