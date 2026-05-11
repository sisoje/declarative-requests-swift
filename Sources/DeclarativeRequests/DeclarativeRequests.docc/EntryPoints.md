# Building and Sending Requests

Entry points for turning a list of blocks into a `URLRequest`.

## Overview

There are several equivalent ways to build a request. Pick the one that
fits your call site:

```swift
// From scratch -- BaseURL inside the builder sets the URL:
let request = try URLRequest {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/health")
}

// From an existing URL:
let api = URL(string: "https://api.example.com")!
let request = try api.buildRequest {
    Method.GET
    Endpoint("v1", "users", userId)
}

// Inspect the wire format:
print(request.curlCommand)
```

## Topics

### Creating a Request

- ``Foundation/URLRequest/init(builder:)``
- ``Foundation/URL/buildRequest(builder:)``
- ``RequestBuildable/request``

### Debugging

- ``Foundation/URLRequest/curlCommand``
