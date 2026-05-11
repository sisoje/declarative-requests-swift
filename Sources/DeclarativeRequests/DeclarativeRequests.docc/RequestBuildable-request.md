# ``RequestBuildable/request``

Build a fresh `URLRequest` by applying this value's transform to a new ``RequestState``.

## Overview

The `request` property is the final step that turns a declarative block
composition into a concrete `URLRequest`. It creates a blank
``RequestState``, runs every block's transform in declaration order, and
returns the finished request.

```swift
let request = try RequestBlock {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/health")
}.request
```

Most of the time you won't call `request` directly — the convenience
initializers ``Foundation/URLRequest/init(builder:)`` and
``Foundation/URL/buildRequest(builder:)`` do this for you. Use `request`
when you're working with a custom ``RequestBuildable`` value or composing
blocks programmatically.

- Throws: ``DeclarativeRequestsError`` if any block fails to apply
  (typically because of a malformed URL or a body that could not be
  encoded).
