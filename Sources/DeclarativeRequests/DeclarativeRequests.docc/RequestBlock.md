# ``RequestBlock``

A leaf in the request DSL -- a value that holds a raw state-transform closure.

## Overview

`RequestBlock` is the primitive ``RequestBuildable`` that all other blocks
reduce to. You construct one in two ways:

1. From a closure that mutates ``RequestState`` directly:

   ```swift
   let block = RequestBlock { state in
       state.request.timeoutInterval = 30
   }
   ```

2. From a `@RequestBuilder` closure, which lets you compose other blocks:

   ```swift
   let block = RequestBlock {
       Method.POST
       Endpoint("/users")
       RequestBody.json(payload)
   }
   ```

The latter form is the entry point for building a request from a list of blocks
without going through ``Foundation/URLRequest/init(builder:)``.

> Important: ``body`` is unused for a `RequestBlock` (it is a leaf). Calling it
> traps; the result builder routes around it via the `transform` closure.

### init(_:)

Lift a raw transform closure into a ``RequestBuildable``.

- Parameter transform: A closure that mutates ``RequestState``.

### init(builder:)

Compose a series of blocks into a single ``RequestBlock``.

```swift
let block = RequestBlock {
    Method.GET
    Endpoint("/users")
}
let request = try block.request
```

- Parameter builder: A `@RequestBuilder` closure that produces the
  composition.

## Topics

### Creating a Block
- ``init(_:)``
- ``init(builder:)``

### Composing

- ``body``
- ``request``
