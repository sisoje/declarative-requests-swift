# ``RequestBody/urlEncoded(_:)``

A `application/x-www-form-urlencoded` body.

## Overview

There are two overloads of `urlEncoded`:

**URLQueryItem array** -- Items are encoded in the supplied order;
duplicate names are preserved (`a=1&a=2&b=3`).

```swift
RequestBody.urlEncoded([
    URLQueryItem(name: "grant_type", value: "password"),
    URLQueryItem(name: "username", value: "alice"),
])
```

**Encodable model** -- Top-level fields become form items. Nested arrays
use bracket-indexed keys (`tags[0]=a&tags[1]=b`). Booleans serialize as
`"true"`/`"false"`. Dictionary keys are emitted in alphabetical order so
the body is deterministic.

```swift
RequestBody.urlEncoded(loginForm)
RequestBody.urlEncoded(["grant_type": "password", "username": "alice"])
```

- Parameters:
  - items: The form items (or encodable model) to encode.
