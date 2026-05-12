# ``AuthorizationHeader/basic(username:password:)``

Sets `Authorization: Basic <base64>` (RFC 7617).

## Overview

The username and password are joined with a colon, UTF-8 encoded, and Base64-encoded
automatically.

```swift
AuthorizationHeader.basic(username: "alice", password: "s3cret")
// -> Authorization: Basic YWxpY2U6czNjcmV0
```

- Parameters:
  - username: The username.
  - password: The password.
