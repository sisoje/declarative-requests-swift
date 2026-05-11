# ``RequestState/subscript(_:_:)``

Generate a ``RequestBlock`` that writes a value through a key path on ``RequestState``.

## Overview

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
