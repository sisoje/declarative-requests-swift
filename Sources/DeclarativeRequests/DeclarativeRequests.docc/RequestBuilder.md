# ``RequestBuilder``

The result builder that powers the request DSL.

## Overview

`RequestBuilder` accumulates ``RequestBuildable`` values declared inside a builder
closure and folds them into a single ``RequestBlock`` whose transform applies each
piece in declaration order. You don't call its static methods yourself — the Swift
compiler does, when it sees a closure marked `@RequestBuilder`:

```swift
let request = try URLRequest {           // compiler invokes RequestBuilder
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/users")
    if hasToken {
        Authorization.bearer(token)
    }
    for header in extraHeaders {
        Header.custom(header.name).setValue(header.value)
    }
}
```

The builder supports the full set of structural forms:
- sequential statements (folded into a partial block),
- `if` / `if`-`else` / `switch` (via `buildEither`),
- optional `if` (via `buildOptional`),
- `for`-`in` loops (via `buildArray`),
- `if #available` (via `buildLimitedAvailability`).

Passing a non-``RequestBuildable`` value into the builder is rejected at compile
time by the unavailable `buildExpression` overload.

### buildExpression (unavailable)

Compile-time guard that rejects any expression that isn't a
``RequestBuildable``. Always traps; exists only for diagnostics.

### buildBlock

Produce an empty block when the builder closure has no statements.

### buildPartialBlock(first:)

First component in a partial-block accumulation.

Called by the compiler for the first statement in a builder closure when
using `buildPartialBlock`-style accumulation.

- Parameter first: The first ``RequestBuildable`` declared.
- Returns: A ``RequestBlock`` representing only that statement.

### buildPartialBlock(accumulated:next:)

Combine the running partial result with the next statement.

- Parameters:
  - accumulated: The composition built up so far.
  - next: The next statement encountered in the builder closure.
- Returns: A ``RequestBlock`` whose transform runs `accumulated` then `next`.

### buildExpression(_:)

Translate a single statement expression into a ``RequestBlock``.

- Parameter component: The ``RequestBuildable`` declared.
- Returns: That value wrapped as a ``RequestBlock``.

### buildEither(first:)

Build the `if` branch of an `if`-`else` (or `switch`) statement.

- Parameter component: The block produced by the first branch.
- Returns: That block, type-erased into a ``RequestBlock``.

### buildEither(second:)

Build the `else` branch of an `if`-`else` (or `switch`) statement.

- Parameter component: The block produced by the second branch.
- Returns: That block, type-erased into a ``RequestBlock``.

### buildOptional(_:)

Build an `if` statement that has no `else`.

- Parameter component: The block produced when the condition is true,
  or `nil` when the condition is false.
- Returns: A ``RequestBlock`` that applies the inner transform when present
  and is a no-op otherwise.

### buildArray(_:)

Build a `for`-`in` loop by combining the iteration results.

- Parameter components: One ``RequestBuildable`` per iteration.
- Returns: A ``RequestBlock`` that applies each iteration's transform in
  order.

### buildLimitedAvailability(_:)

Erase a partial result wrapped by `if #available`.

- Parameter component: The block produced inside the availability check.
- Returns: That block, with no version-specific type information leaking
  into the surrounding builder.

## Topics

### Builder Methods
- ``buildBlock()``
- ``buildPartialBlock(first:)``
- ``buildPartialBlock(accumulated:next:)``
- ``buildExpression(_:)-1mzgd``
- ``buildEither(first:)``
- ``buildEither(second:)``
- ``buildOptional(_:)``
- ``buildArray(_:)``
- ``buildLimitedAvailability(_:)``
