# ``Foundation/URL``

Convenience extension for building a request from an existing URL.

@Metadata {
    @DisplayName("URL Extensions")
}

## Overview

When you already have a `URL` value — from a configuration file, a server
response, or a computed property — ``buildRequest(builder:)`` lets you use
it directly as the base without repeating it inside a ``BaseURL`` block.

```swift
let api = URL(string: "https://api.example.com")!

let users = try api.buildRequest {
    Method.GET
    Endpoint("v1", "users")
    Query("page", "2")
    Header(.accept, "application/json")
}

let health = try api.buildRequest {
    Method.GET
    Endpoint("health")
}
```

The receiver is implicitly treated as the ``BaseURL``; any ``Endpoint``,
``Query``, ``Header``, or ``RequestBody`` blocks you declare layer on top.
This is a convenience wrapper — it is equivalent to including
`BaseURL(url)` inside a plain ``URLRequest/init(builder:)`` call.

### When to use which entry point

| Entry point | Best for |
|---|---|
| ``URLRequest/init(builder:)`` | Building from scratch, URL declared via ``BaseURL`` |
| ``URL/buildRequest(builder:)`` | You already have a `URL` value |
| ``RequestBuildable/request`` | Advanced: building from a custom ``RequestBuildable`` |

## Topics

### Building a Request

- ``buildRequest(builder:)``
