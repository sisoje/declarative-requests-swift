/// A closure that mutates a ``RequestState`` to apply one piece of a request specification.
///
/// Every ``RequestBuildable`` ultimately reduces to a `RequestStateTransformClosure`
/// (a function from ``RequestState`` to `Void`). The result builder composes these
/// closures in declaration order. You typically don't construct one directly —
/// use ``RequestBlock`` to lift a closure into a ``RequestBuildable``.
public typealias RequestStateTransformClosure = (RequestState) throws -> Void
