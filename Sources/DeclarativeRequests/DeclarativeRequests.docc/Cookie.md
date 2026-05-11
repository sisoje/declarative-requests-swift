# ``Cookie``

Adds a single cookie to the request's `Cookie` header.

## Overview

Multiple `Cookie` declarations accumulate into a single
`Cookie: a=1; b=2` header.

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Cookie("session", token)
    Cookie("locale", "en")
}
```

### init(_:_:)

Create a `Cookie` block.

- `key`: The cookie name.
- `value`: The cookie value.

## Topics

### Creating a Cookie

- ``init(_:_:)``

### Composing

- ``body``
- ``request``
