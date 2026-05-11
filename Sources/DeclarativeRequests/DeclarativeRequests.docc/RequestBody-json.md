# ``RequestBody/json(_:)``

JSON-encodes `value` into the body and sets `Content-Type: application/json`.

## Overview

Uses the request's ``RequestState/encoder``, so any encoder configuration
(date strategy, key strategy, output formatting) you set there is applied.

```swift
RequestBody.json(LoginRequest(email: e, password: p))
```

- Parameters:
  - value: The value to encode.
