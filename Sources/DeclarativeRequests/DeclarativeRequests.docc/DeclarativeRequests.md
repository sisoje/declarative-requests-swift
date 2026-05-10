# ``DeclarativeRequests``

A SwiftUI-style result builder for composing `URLRequest`.

@Metadata {
    @DisplayName("Declarative Requests")
}

## Overview

DeclarativeRequests lets you build HTTP requests the same way SwiftUI builds
views — declare blocks top to bottom, and each block maps onto one piece of
the raw HTTP request.

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/login")
    Header(.accept, "application/json")
    Authorization(bearer: token)
    RequestBody.json(LoginRequest(email: email, password: password))
}
```

Read the builder top to bottom and you read the request top to bottom:
method, URL, headers, body.

### Design principles

- **One type per request property.** `Method` sets the method, `Header` sets
  a header, `RequestBody` sets the body. No god-object configuration structs.
- **Last write wins.** Setting the same property twice replaces the previous
  value — except for blocks that accumulate, like ``Query`` and ``Cookie``.
- **Compose with `body`.** Every block conforms to ``RequestBuildable`` and
  can return other blocks from its `body`, just like a SwiftUI `View`.
  Custom blocks are plain structs — no registration or boilerplate.
- **Control flow built in.** The ``RequestBuilder`` result builder supports
  `if`, `if-else`, `switch`, `for`, and `if #available` out of the box.

### Building and sending

There are several entry points, all equivalent:

```swift
// From scratch — BaseURL inside the builder sets the URL:
let request = try URLRequest {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/health")
}

// From an existing URL:
let request = try URLRequest(url: existingURL) {
    Method.GET
    Path("v1", "users", userId)
}

// Build and send in one call:
let (data, response) = try await URLSession.shared.data {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/users/123")
}
```

### Custom blocks

Conform to ``RequestBuildable`` and return built-in blocks from `body`:

```swift
struct AuthenticatedJSON: RequestBuildable {
    let token: String
    let payload: any Encodable

    var body: some RequestBuildable {
        Method.POST
        Authorization(bearer: token)
        RequestBody.json(payload)
    }
}
```

The recursion terminates automatically at ``RequestBlock`` leaves — no
additional boilerplate required.

## Topics

### Essentials

- ``RequestBuildable``
- ``RequestBuilder``
- ``RequestBlock``
- ``RequestState``

### URL and path

- ``BaseURL``
- ``Endpoint``
- ``Path``
- ``Query``

### Method, headers, and auth

- ``Method``
- ``Header``
- ``Cookie``
- ``Authorization``
- ``ContentType``

### Request body

- ``RequestBody``
- ``MultipartPart``

### Networking knobs

- ``Timeout``
- ``CachePolicy``
- ``NetworkServiceType``
- ``HTTPShouldHandleCookies``
- ``AllowAccess``

### Error handling

- ``DeclarativeRequestsError``
