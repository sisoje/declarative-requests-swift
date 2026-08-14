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
let request = try RequestBlock {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("v1/login")
    Header.accept.setValue("application/json")
    Authorization.bearer(token)
    RequestBody.json(LoginRequest(email: email, password: password))
}.request
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
- **Control flow built in.** The `@RequestBuilder` result builder supports
  `if`, `if-else`, `switch`, `for`, and `if #available` out of the box.

### Building and sending

There are several entry points, all equivalent:

```swift
// From scratch — BaseURL inside the builder sets the URL:
let request = try RequestBlock {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("health")
}.request

// From an existing URL value:
let request = try RequestBlock {
    Method.GET
    Endpoint("v1/users/\(userId)")
}.base(existingURL).request
```

### Control flow

The `@RequestBuilder` result builder supports `if`, `if-else`, `switch`,
and `for` — use them directly inside the builder closure:

```swift
let request = try RequestBlock {
    Method.GET
    Endpoint("v1/users")

    if isStaging {
        Header.custom("X-Env").setValue("staging")
    }

    for (key, value) in extraHeaders {
        Header.custom(key).setValue(value)
    }

    BaseURL("https://api.example.com")
}.request
```

### Custom blocks

Conform to ``RequestBuildable`` and return built-in blocks from `body`:

```swift
struct AuthenticatedJSON: RequestBuildable {
    let token: String
    let payload: any Encodable

    var body: some RequestBuildable {
        Method.POST
        Authorization.bearer(token)
        RequestBody.json(payload)
    }
}
```

The recursion terminates automatically at ``RequestBlock`` leaves — no
additional boilerplate required.

### Backend spec

Declare an endpoint surface as a struct of `@RequestBuilder` closures
and materialize requests on demand. Keeps URL construction out of
call sites and makes endpoints easy to mock in tests:

```swift
struct UserBackend {
    @RequestBuilder var getUser: (_ id: String) -> any RequestBuildable
    @RequestBuilder var refreshToken: (_ token: String) -> any RequestBuildable
}

extension UserBackend {
    static func live(baseURL: URL) -> Self {
        .init(
            getUser: { id in
                Method.GET
                BaseURL(baseURL)
                Endpoint("v1/users/\(id)")
            },
            refreshToken: { token in
                Method.POST
                BaseURL(baseURL)
                Endpoint("v1/auth/refresh")
                RequestBody.json(["token": token])
            }
        )
    }
}

let request = try repo.getUser("42").request
```

### Headers

Headers go directly in the request — `setValue` replaces, `addValue` accumulates:

```swift
let request = try RequestBlock {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("users")

    MIMEType.json.accept
    Header.userAgent.setValue("MyApp/1.0")
    Authorization.bearer(token)
    Header.custom("X-Trace-Id").setValue("abc123")
    if isStaging {
        Header.custom("X-Env").setValue("staging")
    }
}.request
```

### Custom authentication

For signing schemes that derive credentials from the request itself —
like HMAC signatures computed over headers or the body — use a raw
``RequestBlock`` closure. Place it after all other
blocks so the request is fully formed when the closure runs:

```swift
let request = try RequestBlock {
    Method.POST
    Endpoint("v1/data")
    RequestBody.json(payload)
    RequestBlock { state in
        let body = state.request.httpBody ?? Data()
        let signature = hmac(body, secret: key)
        state.request.setValue("Signed \(signature)",
                               forHTTPHeaderField: "Authorization")
    }
    BaseURL("https://api.example.com")
}.request
```

### Multipart uploads

Build multipart bodies with ``MultipartPart`` values inside a
``RequestBody/multipart(boundary:_:)`` block. The encoder follows
RFC 7578: form-field and filename parameters are quoted, `\` and `"` are
escaped, CR/LF in names is stripped (no header injection), and a boundary
containing whitespace or special characters is quoted in the `Content-Type`
header.

## Topics

### Essentials

- ``RequestBuildable``
- ``RequestBlock``
- ``RequestState``

### Builder Blocks


### Building and Sending Requests


### Extensions


### MIME Types

- ``MIMEType``

### Error Handling

