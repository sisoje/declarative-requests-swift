# ``Foundation/URLRequest/init(builder:)``

Build a `URLRequest` from a list of declarative blocks.

## Overview

This is the most direct entry point into the DSL when you don't already
have a `URL` value to root the request at — declare the URL inside the
builder with ``BaseURL`` (and optionally ``Endpoint``):

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/users")
    Header.contentType.setValue("application/json")
    RequestBody.json(payload)
}
```

- Parameter builder: A `@RequestBuilder` closure that declares the
  request's components.
- Throws: ``DeclarativeRequestsError`` if any block fails to apply
  (typically because of a malformed URL or a body that could not be
  encoded).
