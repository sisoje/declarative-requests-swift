# ``Timeout``

Sets the request's timeout interval.

## Overview

Maps to `URLRequest.timeoutInterval`. The default for `URLRequest` is 60
seconds; use `Timeout` to shorten or lengthen it as needed.

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/slow-endpoint")
    Timeout(120)  // 2 minutes
}
```

### init(_ interval: TimeInterval)

Create a `Timeout` block.

- Parameter interval: The maximum time, in seconds, to wait for a
  response.

## Topics

### Creating a Timeout
- ``init(_:)``

### Composing

- ``body``
- ``request``
