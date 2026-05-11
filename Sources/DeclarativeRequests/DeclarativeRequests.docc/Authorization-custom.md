# ``Authorization/custom(_:)``

Sets the `Authorization` header via a custom authenticator closure.

## Overview

The closure receives the in-progress `URLRequest` as an `inout`
parameter after all preceding blocks have been applied. Use this for
authentication schemes that derive credentials from the request itself
-- for example, HMAC signatures computed over headers or the body.

Place this block **after** all headers, query items, and body blocks
so the request is fully formed when the closure runs.

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/data")
    RequestBody.json(payload)
    Authorization.custom { request in
        let body = request.httpBody ?? Data()
        let hash = SHA256.hash(data: body).description
        request.setValue("HMAC \(hash)",
                        forHTTPHeaderField: "Authorization")
    }
}
```

- Parameters:
  - authenticator: A closure that inspects and mutates the in-progress
    request to apply custom authorization.
