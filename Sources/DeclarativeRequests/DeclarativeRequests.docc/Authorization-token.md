# ``Authorization/token(_:)``

Sets `Authorization: Token <token>`.

## Overview

Used by frameworks like Django REST Framework and some CI systems.

```swift
Authorization.token(apiKey)
// -> Authorization: Token abc123
```

- Parameters:
  - token: The token string.
