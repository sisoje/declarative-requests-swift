# ``AuthorizationHeader/raw(_:)``

Sets `Authorization` to a verbatim string — no prefix, no encoding.

## Overview

```swift
AuthorizationHeader.raw("my-opaque-api-key-12345")
// -> Authorization: my-opaque-api-key-12345
```

- Parameter value: The exact header value.
