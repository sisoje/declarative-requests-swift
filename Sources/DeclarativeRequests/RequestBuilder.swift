import Foundation

extension Sequence where Element == RequestStateTransformClosure {
    var reduced: RequestStateTransformClosure {
        reduce({ @Sendable _ in }) { partialResult, closure in
            { @Sendable in
                try partialResult($0)
                try closure($0)
            }
        }
    }
}

/// The result builder that powers the request DSL.
///
/// `RequestBuilder` accumulates ``RequestBuildable`` values declared inside a builder
/// closure and folds them into a single ``RequestBlock`` whose transform applies each
/// piece in declaration order. You don't call its static methods yourself — the Swift
/// compiler does, when it sees a closure marked `@RequestBuilder`:
///
/// ```swift
/// let request = try URLRequest {           // compiler invokes RequestBuilder
///     Method.POST
///     BaseURL("https://api.example.com")
///     Endpoint("/users")
///     if hasToken {
///         Authorization(bearer: token)
///     }
///     for header in extraHeaders {
///         Header.custom(header.name).setValue(header.value)
///     }
/// }
/// ```
///
/// The builder supports the full set of structural forms:
/// - sequential statements (folded into a partial block),
/// - `if` / `if`-`else` / `switch` (via `buildEither`),
/// - optional `if` (via `buildOptional`),
/// - `for`-`in` loops (via `buildArray`),
/// - `if #available` (via `buildLimitedAvailability`).
///
/// Passing a non-``RequestBuildable`` value into the builder is rejected at compile
/// time by the unavailable `buildExpression` overload.
@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    /// Compile-time guard that rejects any expression that isn't a
    /// ``RequestBuildable``. Always traps; exists only for diagnostics.
    @available(*, unavailable, message: "This type is not supported in request builder")
    static func buildExpression<Unsupported>(_: Unsupported) -> RequestBlock {
        fatalError()
    }

    /// Produce an empty block when the builder closure has no statements.
    static func buildBlock() -> RequestBlock {
        RequestBlock {}
    }

    /// First component in a partial-block accumulation.
    ///
    /// Called by the compiler for the first statement in a builder closure when
    /// using `buildPartialBlock`-style accumulation.
    ///
    /// - Parameter first: The first ``RequestBuildable`` declared.
    /// - Returns: A ``RequestBlock`` representing only that statement.
    static func buildPartialBlock(first: any RequestBuildable) -> RequestBlock {
        RequestBlock(first.transform)
    }

    /// Combine the running partial result with the next statement.
    ///
    /// - Parameters:
    ///   - accumulated: The composition built up so far.
    ///   - next: The next statement encountered in the builder closure.
    /// - Returns: A ``RequestBlock`` whose transform runs `accumulated` then `next`.
    static func buildPartialBlock(accumulated: any RequestBuildable, next: any RequestBuildable) -> RequestBlock {
        let lhs = accumulated.transform
        let rhs = next.transform
        return RequestBlock { state in
            try lhs(state)
            try rhs(state)
        }
    }

    /// Translate a single statement expression into a ``RequestBlock``.
    ///
    /// - Parameter component: The ``RequestBuildable`` declared.
    /// - Returns: That value wrapped as a ``RequestBlock``.
    static func buildExpression(_ component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }

    /// Build the `if` branch of an `if`-`else` (or `switch`) statement.
    ///
    /// - Parameter component: The block produced by the first branch.
    /// - Returns: That block, type-erased into a ``RequestBlock``.
    static func buildEither(first component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }

    /// Build the `else` branch of an `if`-`else` (or `switch`) statement.
    ///
    /// - Parameter component: The block produced by the second branch.
    /// - Returns: That block, type-erased into a ``RequestBlock``.
    static func buildEither(second component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }

    /// Build an `if` statement that has no `else`.
    ///
    /// - Parameter component: The block produced when the condition is true,
    ///   or `nil` when the condition is false.
    /// - Returns: A ``RequestBlock`` that applies the inner transform when present
    ///   and is a no-op otherwise.
    static func buildOptional(_ component: (any RequestBuildable)?) -> RequestBlock {
        RequestBlock(component?.transform ?? { @Sendable _ in })
    }

    /// Build a `for`-`in` loop by combining the iteration results.
    ///
    /// - Parameter components: One ``RequestBuildable`` per iteration.
    /// - Returns: A ``RequestBlock`` that applies each iteration's transform in
    ///   order.
    static func buildArray(_ components: [any RequestBuildable]) -> RequestBlock {
        RequestBlock(components.map(\.transform).reduced)
    }

    /// Erase a partial result wrapped by `if #available`.
    ///
    /// - Parameter component: The block produced inside the availability check.
    /// - Returns: That block, with no version-specific type information leaking
    ///   into the surrounding builder.
    static func buildLimitedAvailability(_ component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }
}
