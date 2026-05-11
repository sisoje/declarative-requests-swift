# ``Authorization/other(_:credentials:)``

Sets `Authorization: <scheme> <credentials>` for a scheme not covered by the other factories.

## Overview

```swift
Authorization.other("HOBA", credentials: "...")
// -> Authorization: HOBA ...

Authorization.other("Negotiate", credentials: negotiateToken)
// -> Authorization: Negotiate <token>
```

- Parameters:
  - scheme: The scheme name (e.g. `"HOBA"`, `"Negotiate"`, `"Digest"`).
  - credentials: The credentials string written after the scheme name.
