# ``Foundation/URL/buildRequest(builder:)``

Build a `URLRequest` rooted at this URL using the request DSL.

## Overview

This is the most ergonomic entry point when you already have a `URL` value:

```swift
let api = URL(string: "https://api.example.com")!
let request = try api.buildRequest {
    Method.GET
    Endpoint("v1", "users", userId)
    Header(.accept, "application/json")
}
```

The receiver is implicitly used as the ``BaseURL``; further blocks layer
path components, query items, headers, and body content on top.

- Parameter builder: A `@RequestBuilder` closure that declares the
  request's components.
- Returns: The built `URLRequest`.
- Throws: ``DeclarativeRequestsError`` if any block fails to apply.
