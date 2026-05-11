# ``RequestState``

The mutable scratchpad threaded through every block while a request is being built.

## Overview

`RequestState` holds the in-progress `URLRequest` plus the encoder used by
Encodable-driven blocks (``RequestBody/json(_:)``, ``RequestBody/urlEncoded(_:)-(any_Encodable)``,
``Query``, ``Header/init(_:mode:)-(any_Encodable,_)``). Each ``RequestBuildable``
mutates this state through a ``RequestStateTransformClosure`` and the next
block sees the result.

You typically don't construct a `RequestState` yourself — call
``RequestBuildable/request`` (or one of the convenience entry points like
``URLRequest/init(url:cachePolicy:timeoutInterval:builder:)``) and the
framework manages the lifecycle. Constructing one explicitly is useful for
tests:

```swift
let state = RequestState()
try block.transform(state)
XCTAssertEqual(state.request.httpMethod, "POST")
```

### init(request:encoder:)

Create a new state.

- Parameters:
  - request: The starting `URLRequest`. Defaults to a request rooted at
    a placeholder URL that ``BaseURL`` is expected to replace.
  - encoder: The `JSONEncoder` used by Encodable-driven blocks.

### request

The in-progress request being built. Blocks read and mutate this directly.

### encoder

The encoder used to serialize Encodable values inside body and header blocks.

### cookies

The cookies currently encoded into the `Cookie` header, parsed lazily.

Reads parse the existing header. Writes serialize the dictionary back as a
`name=value; ...` string. Setting an empty dictionary clears the header.

### subscript(_:_:)

Generate a ``RequestBlock`` that writes a value through a key path on
``RequestState``.

This subscript is the primary way internal blocks like ``Method`` and
``Timeout`` express their transform without writing a closure each time:

```swift
public var body: some RequestBuildable {
    RequestState[\.request.timeoutInterval, interval]
}
```

You can use it the same way to write your own one-liner blocks.

- Parameters:
  - keyPath: A writable key path into ``RequestState`` (typically into a
    property of the wrapped `URLRequest`).
  - value: The value to assign. The closure is `@autoclosure` so the
    expression is evaluated lazily and may `throw`.
- Returns: A ``RequestBlock`` that performs the assignment when applied.

## Topics

### Creating a State
- ``init(request:encoder:)``

### Properties
- ``request``
- ``encoder``
- ``cookies``

### Convenience Subscript
- ``subscript(_:_:)``
