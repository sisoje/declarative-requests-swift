# ``Authorization/bearer(_:)``

Sets `Authorization: Bearer <token>` (RFC 6750).

## Overview

The token string is written verbatim after `Bearer `.

```swift
Authorization.bearer(accessToken)
// -> Authorization: Bearer eyJhbGci...
```

- Parameters:
  - token: The bearer token.
