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
    Header.accept.setValue("application/json")
    Authorization.bearer(token)
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
- **Control flow built in.** The `@RequestBuilder` result builder supports
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

// From an existing URL value:
let request = try existingURL.buildRequest {
    Method.GET
    Endpoint("/v1/users/\(userId)")
}
```

### Control flow

The `@RequestBuilder` result builder supports `if`, `if-else`, `switch`,
and `for` — use them directly inside the builder closure:

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")

    if let token = tokenProvider() {
        Authorization.bearer(token)
    }

    for (key, value) in extraHeaders {
        Header.custom(key).setValue(value)
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
        Authorization.bearer(token)
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

### Grouped headers

Top-level ``Header`` and ``Authorization`` blocks work directly inside a request.
When you'd rather keep header declarations visually together — or vary an entire
group conditionally — wrap them in ``Headers`` and use the typed header nodes.
The grouping builder only accepts header values; passing anything else is a
compile-time error:

```swift
let request = try URLRequest {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/users")

    Headers {
        AcceptHeader(.json)
        UserAgentHeader("MyApp/1.0")
        AuthorizationHeader.bearer(token)
        CustomHeader("X-Trace-Id", "abc123")
        if isStaging {
            CustomHeader("X-Env", "staging")
        }
    }
}
```

Each typed node has a default mode (most are set, ``CustomHeader`` is add). Flip
it explicitly with `.headersSet()` or `.headersAdd()` when you need the other one.

### Custom authentication

For signing schemes that derive credentials from the request itself —
like HMAC signatures computed over headers or the body — use the
``Authorization/custom(_:)`` authenticator closure. Place it after all other
blocks so the request is fully formed when the closure runs:

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/data")
    RequestBody.json(payload)
    Authorization.custom { request in
        let body = request.httpBody ?? Data()
        let signature = hmac(body, secret: key)
        request.setValue("Signed \(signature)",
                        forHTTPHeaderField: "Authorization")
    }
}
```

### Multipart uploads

Build multipart bodies with ``MultipartPart`` values inside a
``RequestBody/multipart(boundary:strategy:_:)`` block. The encoder follows
RFC 7578: form-field and filename parameters are quoted, `\` and `"` are
escaped, CR/LF in names is stripped (no header injection), and a boundary
containing whitespace or special characters is quoted in the `Content-Type`
header. For large files, switch to `.streamed()` so memory stays bounded —
that path also sets `Content-Length` up front by stat'ing each file:

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/upload")
    RequestBody.multipart {
        MultipartPart.field(name: "user", value: "alice")
        MultipartPart.data(name: "avatar", filename: "a.png",
                           data: pngBytes, type: .png)
        for url in fileURLs {
            MultipartPart.file(name: "files", fileURL: url, type: .octetStream)
        }
    }
}

// Streamed — memory-efficient for very large uploads:
RequestBody.multipart(strategy: .streamed(bufferSize: 64 * 1024)) {
    MultipartPart.file(name: "video", fileURL: hugeVideoURL, type: .Video.mp4)
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
- ``RequestBlock``
- ``RequestState``

### Builder Blocks

- <doc:BuilderBlocks>

### Headers

- ``Headers``

### Building and Sending Requests

- <doc:EntryPoints>

### Extensions

- ``Foundation/URLRequest``
- ``Foundation/URL``

### MIME Types

- ``MIMEType``
- ``MIMEType/List``

### Error Handling

- ``DeclarativeRequestsError``
