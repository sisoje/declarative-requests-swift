# ``RequestBuildable``

A composable piece of a request specification.

## Overview

`RequestBuildable` is the protocol every block in the DSL conforms to. Each block
describes a transformation that will be applied to a ``RequestState`` when the
final ``URLRequest`` is built. Blocks compose recursively through their `body`,
the same way SwiftUI views compose: a higher-level block returns one or more
lower-level blocks, terminating in primitive ``RequestBlock`` leaves.

You rarely need to write a custom conformance — the built-in blocks
(``BaseURL``, ``Endpoint``, ``Method``, ``Header``, ``RequestBody``, ...)
cover most cases. When you do, return your composition from `body`:

```swift
struct AuthenticatedJSON: RequestBuildable {
    let token: String
    let payload: any Encodable

    var body: some RequestBuildable {
        Method.POST
        Authorization.bearer(token)
        RequestBody.json(payload)
    }
}
```

To produce a final ``URLRequest``, call ``request`` on any conforming value.

### Body

The blocks this value is composed of.

Return one or more ``RequestBuildable`` values inside an `@RequestBuilder`
closure. The result builder folds them into a single transform applied in
declaration order.

### request

Build a fresh `URLRequest` by applying this value's transform to a new
``RequestState``.

```swift
let request = try RequestBlock {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/health")
}.request
```

- Returns: The built `URLRequest`.
- Throws: ``DeclarativeRequestsError`` if any block fails to apply
  (typically because of a malformed URL or a body that could not be encoded).

### transform

The flattened state-transform represented by this value.

For the leaf ``RequestBlock`` type, returns the closure directly. For any
other conformer, recurses into `body` until it reaches leaves.

## Topics

### Associated Types
- ``Body``

### Building Requests
- ``request``
- ``body``
