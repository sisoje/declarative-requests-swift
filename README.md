# Declarative Requests

[![Build](https://github.com/sisoje/declarative-requests-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/sisoje/declarative-requests-swift/actions/workflows/swift.yml)

A SwiftUI-style result builder for composing `URLRequest`. Each block in the
builder maps onto one piece of a raw HTTP request — read the builder top to
bottom and you read the request top to bottom.

```http
POST /v1/login HTTP/1.1
Host: api.example.com
Accept: application/json
Authorization: Bearer eyJhbGci...
Content-Type: application/json

{"email":"alice@example.com","password":"hunter2"}
```

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/login")
    Header(.accept, "application/json")
    Authorization.bearer(token)
    RequestBody.json(LoginRequest(email: email, password: password))
}
```

Each `Header(...)` is one HTTP-line. `RequestBody.json(...)` is the body
section. The block order roughly mirrors the wire order.

## Block reference

One type per request property. Pick the factory or initializer that matches
the data you have.

### URL & path

| Block | What it does | Example |
|---|---|---|
| `BaseURL(_:)` | Sets host/scheme; preserves any path/query already declared. | `BaseURL("https://api.example.com")` |
| `Endpoint(_:...)` | Resolves segments against the current path using RFC 3986 reference resolution (like Python's `urljoin`). Bare segments append, leading `/` resets to root, `..`/`.` traverse. | `Endpoint("users", "\(id)", "posts")` |
| `Query(_ name:, _ value:)` | Append a single query item (accumulates). | `Query("page", "2")` |
| `Query(_ encodable:)` | Flatten an `Encodable` model into query items. | `Query(filterModel)` |

### Method, headers, cookies, auth

| Block | What it does | Example |
|---|---|---|
| `Method.GET` / `.POST` / `.PUT` / … / `.custom("LINK")` | Sets the HTTP method. | `Method.POST` |
| `Header(_ field:, _ value:)` | Sets one header by ``Header``. | `Header(.accept, "application/json")` |
| `Header(_ name:, _ value:)` | Sets one header by literal name. | `Header("X-Trace-Id", "abc123")` |
| `…  mode: .add` | Append (comma-list) instead of replace. | `Header(.accept, "text/html", mode: .add)` |
| `Header(_ map:)` | Bulk set from `[Field: String]` or `[String: String]`. | `Header([.accept: "application/json"])` |
| `Header(_ encodable:)` | Bulk set from a flat `Encodable` model. | `Header(MyHeadersModel())` |
| `Cookie(_ name:, _ value:)` | Adds one cookie to the `Cookie` header (accumulates). | `Cookie("session", token)` |
| `Authorization.bearer(_:)` | `Authorization: Bearer …` (RFC 6750) | `Authorization.bearer(token)` |
| `Authorization.basic(username:password:)` | `Authorization: Basic …` (RFC 7617, Base64-encoded) | `Authorization.basic(username: u, password: p)` |
| `Authorization.token(_:)` | `Authorization: Token …` (e.g. Django REST) | `Authorization.token(apiKey)` |
| `Authorization.other(_:credentials:)` | `Authorization: <Scheme> <credentials>` | `Authorization.other("HOBA", credentials: "…")` |
| `Authorization.raw(_:)` | Verbatim value, no scheme prefix | `Authorization.raw("opaque-key")` |
| `Authorization.custom { … }` | Closure receives `inout URLRequest` for computed auth | `Authorization.custom { req in … }` |
| `ContentType(_:)` | Sets `Content-Type` from a `MIMEType`. | `ContentType(.json)` |
| `Accept(_:)` | Accumulates `Accept` header values. | `Accept(.json)` |

### Body — one type, many factories

`RequestBody` is **the** body block. The factory you pick decides how the
bytes are produced and what (if any) `Content-Type` is set:

| Factory | What you supply | Sets `Content-Type` |
|---|---|---|
| `RequestBody.data(_ data:type:)` | `Data` + optional `ContentType` | only if you pass `type:` |
| `RequestBody.string(_ s:type:)` | `String` (UTF-8) + `ContentType` | yes (defaults `text/plain`) |
| `RequestBody.json(_ value:)` | `Encodable` value | `application/json` |
| `RequestBody.urlEncoded(_ items:)` | `[URLQueryItem]` | `application/x-www-form-urlencoded` |
| `RequestBody.urlEncoded(_ encodable:)` | `Encodable` (incl. `[String:String]`) | `application/x-www-form-urlencoded` |
| `RequestBody.stream(_ stream:)` | `InputStream` (autoclosure) | no — pair with `Header(.contentType, …)` if needed |
| `RequestBody.multipart { parts }` | `MultipartPart`s, in-memory | `multipart/form-data; boundary=…` |
| `RequestBody.multipart(strategy: .streamed()) { parts }` | `MultipartPart`s, streamed from disk | `multipart/form-data; boundary=…` + `Content-Length` |

The body is *replaced* by each `RequestBody.*` block — last one wins. To
collect form items across iterations, build the array first and pass it
once.

### Networking knobs

| Block | What it does |
|---|---|
| `Timeout(_ seconds:)` | `request.timeoutInterval` |
| `CachePolicy(.reloadIgnoringLocalCacheData)` | `request.cachePolicy` |
| `NetworkServiceType(.background)` | `request.networkServiceType` |
| `HTTPShouldHandleCookies(false)` | `request.httpShouldHandleCookies` |
| `AllowAccess.cellular(true)` etc. | `allowsCellularAccess` / `allowsExpensiveNetworkAccess` / `allowsConstrainedNetworkAccess` / `allowsUltraConstrainedNetworkAccess` |

## Multipart upload

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/upload")
    RequestBody.multipart {
        MultipartPart.field(name: "user", value: "alice")
        MultipartPart.data(name: "avatar", filename: "a.png", data: pngBytes, type: .png)
        for url in fileURLs {
            MultipartPart.file(name: "files", fileURL: url, type: .octetStream)
        }
    }
}
```

For very large uploads, switch to streaming so memory use stays bounded:

```swift
RequestBody.multipart(strategy: .streamed(bufferSize: 64 * 1024)) {
    MultipartPart.field(name: "title", value: "Vacation 2026")
    MultipartPart.file(name: "video", fileURL: hugeVideoURL, type: .Video.mp4)
}
```

## Building from a base URL

If you already have a `URL`, hand it to the initializer:

```swift
let request = try URLRequest(url: api) {
    Method.GET
    Endpoint("v1", "users", userId)
    Header(.accept, "application/json")
}
```

Or skip constructing the `URL` yourself:

```swift
let request = try URLRequest(string: "https://api.example.com") {
    Method.POST
    Endpoint("/login")
    RequestBody.json(credentials)
}
```

`url` and `string` are optional — if you omit them, the builder is expected
to set the URL via `BaseURL(...)`.

## Sending requests

For a one-line build-and-send through `URLSession`:

```swift
let (data, response) = try await URLSession.shared.data {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/users/123")
}

// Decoding directly:
struct User: Decodable { let id: Int; let name: String }
let user = try await URLSession.shared.decode(User.self) {
    Method.GET
    BaseURL("https://api.example.com")
    Endpoint("/users/123")
}
```

## Repository pattern

Declare an endpoint surface as a struct of `@RequestBuilder` closures and
materialize requests on demand. Keeps URL construction out of call sites
and makes endpoints easy to mock in tests.

```swift
struct UserRepository {
    @RequestBuilder var getUser: (_ id: String) -> any RequestBuildable
    @RequestBuilder var refreshToken: (_ token: String) -> any RequestBuildable
}

extension UserRepository {
    static func live(baseURL: URL, tokenProvider: @escaping () -> String?) -> Self {
        .init(
            getUser: { id in
                Method.GET
                BaseURL(baseURL)
                Endpoint("/v1/users/\(id)")
                if let t = tokenProvider() { Authorization.bearer(t) }
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

## Debugging

Every `URLRequest` exposes a copy-pasteable `curl` equivalent:

```swift
print(request.curlCommand)
// curl -X POST -H 'Content-Type: application/json' --data-binary '{"x":1}' 'https://api.example.com/foo'
```

## Architecture sketch

```mermaid
flowchart LR
    RequestBuilder --- transforms ---> RequestState

    subgraph RequestState
        baseUrl["base URL"]
        request
        path["path components"]
        baseUrl --> finalUrl["final URL"]
        path --> finalUrl
    end

    request --> FinalRequest["final request"]
    finalUrl --> FinalRequest

    subgraph RequestBuilder
        function1 --> function2
        function2 --> dots["..."]
        dots --> functionN
    end
```

## Block map

Every block and its variants at a glance:

```mermaid
flowchart LR
    RB["@RequestBuilder { }"]

    %% URL & Endpoint
    RB --> URL_GROUP["URL & Endpoint"]
    URL_GROUP --> BaseURL["BaseURL(_ string)"]
    URL_GROUP --> Endpoint["Endpoint(_ segments...)"]
    URL_GROUP --> Query
    Query --> Q1["Query(_ name, _ value)"]
    Query --> Q2["Query(_ encodable)"]

    %% Method
    RB --> MethodGroup["Method"]
    MethodGroup --> MSTD[".GET  .POST  .PUT\n.DELETE  .PATCH  .HEAD\n.OPTIONS  .TRACE  .CONNECT"]
    MethodGroup --> MCUSTOM[".custom(_ string)"]

    %% Headers
    RB --> HeaderGroup["Headers"]
    HeaderGroup --> Header
    Header --> H1["Header(_ field, _ value)"]
    Header --> H2["Header(_ name, _ value)"]
    Header --> H3["Header(_ fieldMap)"]
    Header --> H4["Header(_ stringMap)"]
    Header --> H5["Header(_ encodable)"]
    Header --> HMode["mode: .set | .add"]
    HeaderGroup --> Cookie["Cookie(_ name, _ value)"]
    HeaderGroup --> ContentType
    ContentType --> CTJSON[".JSON  .XML  .HTML\n.PlainText  .CSV  .PDF\n.PNG  .JPEG  .GIF  .MP4\n.Stream  … 40+ cases"]

    %% Auth
    RB --> AuthGroup["Authorization"]
    AuthGroup --> A1["Authorization.bearer(token)"]
    AuthGroup --> A2["Authorization.basic(username:password:)"]
    AuthGroup --> A3["Authorization.token(apiKey)"]
    AuthGroup --> A4["Authorization.other(scheme, credentials:)"]
    AuthGroup --> A5["Authorization.raw(value)"]
    AuthGroup --> A6["Authorization.custom { inout request in }"]

    %% Body
    RB --> BodyGroup["RequestBody"]
    BodyGroup --> B1[".data(_ data, type:)"]
    BodyGroup --> B2[".string(_ string, type:)"]
    BodyGroup --> B3[".json(_ encodable)"]
    BodyGroup --> B4[".urlEncoded(_ items)"]
    BodyGroup --> B5[".urlEncoded(_ encodable)"]
    BodyGroup --> B6[".stream(_ inputStream)"]
    BodyGroup --> B7[".multipart { parts }"]
    B7 --> MP["MultipartPart"]
    MP --> MP1[".field(name:value:)"]
    MP --> MP2[".data(name:filename:data:type:)"]
    MP --> MP3[".file(name:fileURL:type:)"]
    B7 --> MS["strategy:"]
    MS --> MS1[".inMemory"]
    MS --> MS2[".streamed(bufferSize:)"]

    %% Networking knobs
    RB --> NetGroup["Networking Knobs"]
    NetGroup --> Timeout["Timeout(_ seconds)"]
    NetGroup --> CachePolicy["CachePolicy(_ policy)"]
    NetGroup --> NST["NetworkServiceType(_ type)"]
    NetGroup --> HSHC["HTTPShouldHandleCookies(_ flag)"]
    NetGroup --> AllowAccess
    AllowAccess --> AA1[".cellular(Bool)"]
    AllowAccess --> AA2[".expensiveNetwork(Bool)"]
    AllowAccess --> AA3[".constrainedNetwork(Bool)"]
    AllowAccess --> AA4[".ultraConstrainedNetwork(Bool)"]
```

## Key concepts

- **`RequestBuildable`** — the protocol every block conforms to.
- **`RequestBuilder`** — the `@resultBuilder` that stitches blocks together.
- **`RequestBlock`** — the leaf block; holds a closure that mutates `RequestState`.
- **`RequestState`** — the in-progress `URLRequest` plus the `JSONEncoder` that body / header / query blocks use.
- **`URLRequest { … }.request`** — applies the composed transform to a fresh `RequestState` and returns the finished `URLRequest`.
