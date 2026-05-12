# ``AuthorizationHeader/scheme(_:value:)``

Sets `Authorization: <scheme> <value>` for a scheme not covered by the named factories.

## Overview

```swift
AuthorizationHeader.scheme("ApiKey", value: "k-1")
// -> Authorization: ApiKey k-1

AuthorizationHeader.scheme("HOBA", value: "...")
// -> Authorization: HOBA ...
```

- Parameters:
  - scheme: The scheme name (e.g. `"ApiKey"`, `"HOBA"`, `"Negotiate"`).
  - value: The credentials string written after the scheme name.
