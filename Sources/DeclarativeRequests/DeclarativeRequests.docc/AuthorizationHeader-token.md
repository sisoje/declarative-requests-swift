# ``AuthorizationHeader/token(_:)``

Sets `Authorization: Token <token>`.

## Overview

Used by frameworks like Django REST Framework and some CI systems.

```swift
AuthorizationHeader.token(apiKey)
// -> Authorization: Token abc123
```

- Parameter token: The token string.
