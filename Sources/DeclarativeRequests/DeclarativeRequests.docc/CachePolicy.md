# ``CachePolicy``

Sets the request's cache policy.

## Overview

Maps to `URLRequest.cachePolicy`. Useful for opting individual requests out
of the shared `URLCache` (e.g. polling endpoints) or for forcing a fresh
fetch in response to user-initiated reloads.

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/feed")
    CachePolicy(.reloadIgnoringLocalCacheData)
}
```

### init(_ policy: URLRequest.CachePolicy)

Create a `CachePolicy` block.

- Parameter policy: The cache policy to apply.

## Topics

### Creating a CachePolicy
- ``init(_:)``

### Composing

- ``body``
- ``request``
