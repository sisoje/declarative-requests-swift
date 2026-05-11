# ``BaseURL``

Sets the base URL the request resolves against.

## Overview

`BaseURL` resolves the in-progress URL components against the supplied URL.
Endpoint and query components declared by other blocks are preserved across the
resolution, so the order of declarations doesn't matter for typical cases:

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

The ``URLRequest/init(url:cachePolicy:timeoutInterval:builder:)`` and
``URLRequest/init(string:cachePolicy:timeoutInterval:builder:)`` initializers
wrap this for you, so reach for `BaseURL` when you're staying inside a
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
- ``init(_:)-4bwg2``
- ``init(_:)-9jejp``

### Composing

- ``body``
- ``request``
