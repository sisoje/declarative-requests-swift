# ``RequestBody/urlEncoded(_:)-([URLQueryItem])``

A `application/x-www-form-urlencoded` body assembled from explicit query items.

## Overview

Items are encoded in the supplied order; duplicate names are preserved
(`a=1&a=2&b=3`). Sets `Content-Type: application/x-www-form-urlencoded`.

```swift
RequestBody.urlEncoded([
    URLQueryItem(name: "grant_type", value: "password"),
    URLQueryItem(name: "username", value: "alice"),
])
```

- Parameter items: The form items to encode.
