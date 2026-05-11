# ``RequestBody/data(_:type:)``

A `Data` body, optionally tagged with a `Content-Type`.

## Overview

```swift
RequestBody.data(jpegData, type: .jpeg)
```

If `type` is `nil`, any existing `Content-Type` header is left untouched.

- Parameters:
  - data: The body bytes.
  - type: The content type to set on the request, or `nil` to leave any
    existing `Content-Type` untouched.
