# ``HTTPShouldHandleCookies``

Toggles automatic cookie handling for the request.

## Overview

Maps to `URLRequest.httpShouldHandleCookies`. When `false`, `URLSession`
won't read or write cookies for this request via the shared
`HTTPCookieStorage`. Useful when you're managing cookies manually (e.g.
for tests, or for an authentication flow that uses out-of-band tokens).

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/oauth/token")
    HTTPShouldHandleCookies(false)
}
```

### init(_ value: Bool)

Create an `HTTPShouldHandleCookies` block.

- Parameter value: `true` to use the shared cookie storage, `false` to
  bypass it.

## Topics

### Creating an HTTPShouldHandleCookies
- ``init(_:)``

### Composing

- ``body``
- ``request``
