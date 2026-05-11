# ``NetworkServiceType``

Sets the request's network service type, hinting at the kind of traffic it represents.

## Overview

Maps to `URLRequest.networkServiceType`. The system uses this hint to make
scheduling and quality-of-service decisions -- e.g. `.background` lets the
OS defer the request when the device is on a metered connection, while
`.responsiveData` indicates user-initiated traffic that should be
prioritized.

```swift
let request = try URLRequest {
    BaseURL("https://uploads.example.com")
    Endpoint("/sync")
    NetworkServiceType(.background)
}
```

### init(_ type: URLRequest.NetworkServiceType)

Create a `NetworkServiceType` block.

- Parameter type: The service type to apply.

## Topics

### Creating a NetworkServiceType
- ``init(_:)``

### Composing

- ``body``
- ``request``
