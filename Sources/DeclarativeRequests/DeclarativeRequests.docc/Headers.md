# ``Headers``

Groups one or more header nodes into a single composite block.

## Overview

`Headers` accepts only ``HeaderBuildable`` values via its ``HeadersBuilder`` — anything
else is a compile-time error. Use it to keep header declarations visually together inside
a request, or to group them conditionally:

```swift
let request = try URLRequest {
    Method.GET
    Endpoint("/users")

    Headers {
        AcceptHeader(.json)
        UserAgentHeader("DR/1.0")
        AuthorizationHeader.bearer(token)
        CustomHeader("X-Trace-Id", "abc123")
        if isStaging {
            CustomHeader("X-Env", "staging")
        }
    }
}
```

Direct header expressions (``Header/setValue(_:)``, ``Header/addValue(_:)``) still work
outside of `Headers { }` at the top level of a request — the grouping is opt-in.

## Topics

### Creating

- ``init(_:)``
