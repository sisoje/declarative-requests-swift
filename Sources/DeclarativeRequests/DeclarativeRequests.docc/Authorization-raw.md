# ``Authorization/raw(_:)``

Sets the `Authorization` header to a verbatim string with no scheme prefix.

## Overview

For APIs that expect an opaque key or token without a named scheme.

```swift
Authorization.raw("my-opaque-api-key-12345")
// -> Authorization: my-opaque-api-key-12345
```

- Parameters:
  - value: The exact header value.
