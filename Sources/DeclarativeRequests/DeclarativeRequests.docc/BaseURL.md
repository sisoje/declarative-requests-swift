# ``BaseURL``

Sets the base URL the request resolves against.

## Overview

`BaseURL` fills in the scheme, user, password, host and port of the request URL
from the supplied URL. Any path, query items or fragment already set by other
blocks are preserved, and the base's own path is adopted only if the request
doesn't have one yet. Because the merge touches only the authority components,
the order of `BaseURL`, `Endpoint` and `Query` blocks doesn't matter:

```swift
// Either order produces the same final URL:
let a = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/users")
}
let b = try URLRequest {
    Endpoint("/users")
    BaseURL("https://api.example.com")
}
```

``Foundation/URL/buildRequest(builder:)`` wraps this for you when you already have a
`URL` value, so reach for `BaseURL` when you're staying inside a
`URLRequest { ... }` builder closure or want to override the URL late in a
composition.

### init(_ url: URL?)

Create a `BaseURL` from a `URL` value.

Passing `nil` produces a block that throws ``DeclarativeRequestsError/badUrl``
when applied -- convenient when you're computing a URL from an optional and
want the failure to surface as a thrown error rather than a crash.

- Parameter url: The base URL, or `nil` to throw at build time.

### init(_ string: String)

Create a `BaseURL` from a string.

If the string can't be parsed by `URL(string:)`, the block throws
``DeclarativeRequestsError/badUrl`` when applied.

- Parameter string: The base URL as a string.

## Topics

### Creating a BaseURL
- ``init(_:)-(URL?)``
- ``init(_:)-(String)``

### Composing

- ``body``
- ``request``
