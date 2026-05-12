# ``AuthorizationHeader``

`Authorization` header. Namespace for the supported auth schemes.

## Overview

Mirrors the style used by ``RequestBody`` and the top-level ``Authorization``: an empty
enum with one static factory per scheme. Each factory takes its natural arguments and
formats the header value for you:

```swift
Headers {
    AuthorizationHeader.bearer(jwt)                              // Bearer <jwt>
    AuthorizationHeader.basic(username: "alice", password: "🔑") // Basic <base64>
    AuthorizationHeader.token(apiKey)                            // Token <key>
    AuthorizationHeader.scheme("ApiKey", value: "k-1")           // ApiKey k-1
    AuthorizationHeader.raw("verbatim")                          // verbatim
}
```

There is no `init` — use ``raw(_:)`` when you want to pass a fully-formed value with no
prefix.

## Topics

### Factory Methods

- ``bearer(_:)``
- ``basic(username:password:)``
- ``token(_:)``
- ``scheme(_:value:)``
- ``raw(_:)``
