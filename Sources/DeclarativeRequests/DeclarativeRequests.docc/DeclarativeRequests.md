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

### Control flow

The ``RequestBuilder`` result builder supports `if`, `if-else`, `switch`,
and `for` — use them directly inside the builder closure:

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")

    if let token = tokenProvider() {
        Authorization(bearer: token)
    }

    for (key, value) in extraHeaders {
        Header(key, value)
    }
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

### Repository pattern

Declare an endpoint surface as a struct of `@RequestBuilder` closures
and materialize requests on demand. Keeps URL construction out of
call sites and makes endpoints easy to mock in tests:

```swift
struct UserRepository {
    @RequestBuilder var getUser: (_ id: String) -> any RequestBuildable
    @RequestBuilder var refreshToken: (_ token: String) -> any RequestBuildable
}

extension UserRepository {
    static func live(baseURL: URL) -> Self {
        .init(
            getUser: { id in
                Method.GET
                BaseURL(baseURL)
                Endpoint("/v1/users/\(id)")
            },
            refreshToken: { token in
                Method.POST
                BaseURL(baseURL)
                Endpoint("/v1/auth/refresh")
                RequestBody.json(["token": token])
            }
        )
    }
}

let request = try repo.getUser("42").request
```

### Custom authentication

For signing schemes that derive credentials from the request itself —
like HMAC signatures computed over headers or the body — use the
``Authorization/init(_:)`` authenticator closure. Place it after all other
blocks so the request is fully formed when the closure runs:

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/data")
    Header(.contentType, "application/json")
    RequestBody.json(payload)
    Authorization { request in
        let body = request.httpBody ?? Data()
        let signature = hmac(body, secret: key)
        request.setValue("Signed \(signature)",
                        forHTTPHeaderField: "Authorization")
    }
}
```

### Multipart uploads

Build multipart bodies with ``MultipartPart`` values inside a
``RequestBody/multipart(boundary:strategy:parts:)`` block. For large files,
switch to `.streamed()` so memory stays bounded:

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/upload")
    RequestBody.multipart {
        MultipartPart.field(name: "user", value: "alice")
        MultipartPart.data(name: "avatar", filename: "a.png",
                           data: pngBytes, type: .PNG)
        for url in fileURLs {
            MultipartPart.file(name: "files", fileURL: url, type: .Stream)
        }
    }
}

// Streamed — memory-efficient for very large uploads:
RequestBody.multipart(strategy: .streamed(bufferSize: 64 * 1024)) {
    MultipartPart.file(name: "video", fileURL: hugeVideoURL, type: .MP4)
}
```

### Debugging

Every `URLRequest` exposes a copy-pasteable `curl` equivalent:

```swift
print(request.curlCommand)
// curl -X POST -H 'Content-Type: application/json'
//   --data-binary '{"x":1}' 'https://api.example.com/foo'
```

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
