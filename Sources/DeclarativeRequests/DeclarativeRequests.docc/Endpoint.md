# ``Endpoint``

Appends a path to the request URL.

## Overview

`Endpoint` performs RFC 3986 reference resolution against the current
request URL. A bare path segment is appended (treating the existing
path as a directory), a leading `/` resets to the root, and relative
traversals like `..` and `.` work as expected:

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com/v1/")
    Endpoint("users")
}
// -> https://api.example.com/v1/users
```

Because `Endpoint` resolves against whatever URL is already in the
request state, you can layer multiple endpoints to build deep paths
incrementally:

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/v2")
    Endpoint("users")
    Endpoint("42")
}
// -> https://api.example.com/v2/users/42
```

A leading `/` resets to the host root, which is useful when the base
URL already includes a path prefix you want to override:

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com/v1/old")
    Endpoint("/v2/new")
}
// -> https://api.example.com/v2/new
```

Pair `Endpoint` with ``BaseURL`` for a clean separation between the
host and the resource path. The order of the two blocks doesn't matter
-- `BaseURL` resolves components so that query items and path segments
declared by other blocks are preserved:

```swift
let request = try URLRequest {
    Endpoint("/users")
    BaseURL("https://api.example.com")
    Query("page", "1")
}
// -> https://api.example.com/users?page=1
```

## Topics

### Creating an Endpoint

- ``init(_:)``

### Composing

- ``body``
