# ``RequestBody/urlEncoded(_:)-(Encodable)``

A `application/x-www-form-urlencoded` body assembled from an `Encodable` model.

## Overview

Top-level fields become form items. Nested arrays use bracket-indexed keys
(`tags[0]=a&tags[1]=b`). Booleans serialize as `"true"`/`"false"`. Dictionary
keys are emitted in alphabetical order so the body is deterministic. Sets
`Content-Type: application/x-www-form-urlencoded`.

```swift
RequestBody.urlEncoded(loginForm)
RequestBody.urlEncoded(["grant_type": "password", "username": "alice"])
```

- Parameter encodable: The model to encode via the request's
  ``RequestState/encoder``.
