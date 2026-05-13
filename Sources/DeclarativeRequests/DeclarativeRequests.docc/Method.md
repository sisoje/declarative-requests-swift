# ``Method``

The HTTP method for the request.

## Overview

Use one of the standard cases for typical methods, or ``custom(_:)`` for
methods not covered by the enum (e.g. WebDAV verbs).

```swift
let getRequest = try URLRequest {
    Method.GET
    BaseURL("https://api.example.com")
}

let propfind = try URLRequest {
    Method.custom("PROPFIND")
    BaseURL("https://files.example.com")
}
```

### custom(_:)

Use a non-standard HTTP method.

The string is written verbatim to `URLRequest.httpMethod`, so make sure
it is in the case the server expects.

- `method`: The HTTP method to use.
- Returns: A ``RequestBuildable`` that sets the request's method.

## Topics

### Standard Methods

- ``GET``
- ``HEAD``
- ``POST``
- ``PUT``
- ``DELETE``
- ``CONNECT``
- ``OPTIONS``
- ``TRACE``
- ``PATCH``

### Custom Methods

- ``custom(_:)``

### Composing

- ``body``
- ``request``

### Raw Value

- ``init(rawValue:)``
