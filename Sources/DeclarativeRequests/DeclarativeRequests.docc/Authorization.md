# ``Authorization``

Sets the `Authorization` header.

## Overview

Pick the factory that matches your authentication scheme. Each one
formats the header value for you:

```swift
// OAuth 2.0 bearer token (RFC 6750):
Authorization.bearer(accessToken)
// -> Authorization: Bearer <token>

// HTTP Basic (RFC 7617) -- encodes username:password to Base64 for you:
Authorization.basic(username: "alice", password: "s3cret")
// -> Authorization: Basic YWxpY2U6czNjcmV0

// Token auth (e.g. Django REST Framework):
Authorization.token(apiKey)
// -> Authorization: Token <key>

// Arbitrary "<Scheme> <credentials>" pair:
Authorization.other("HOBA", credentials: "...")
// -> Authorization: HOBA ...

// Verbatim value -- no scheme prefix:
Authorization.raw("my-opaque-key-12345")
// -> Authorization: my-opaque-key-12345

// Custom authenticator -- receives the request built so far:
Authorization.custom { request in
    let signature = hmac(request.allHTTPHeaderFields, secret: key)
    request.setValue("HMAC \(signature)", forHTTPHeaderField: "Authorization")
}
```

### bearer(_:)

Sets `Authorization: Bearer <token>` (RFC 6750).

The token string is written verbatim after `Bearer `.

```swift
Authorization.bearer(accessToken)
// -> Authorization: Bearer eyJhbGci...
```

- `token`: The bearer token.

### basic(username:password:)

Sets `Authorization: Basic <base64>` (RFC 7617).

The username and password are joined with a colon, UTF-8 encoded, and
Base64-encoded automatically.

```swift
Authorization.basic(username: "alice", password: "s3cret")
// -> Authorization: Basic YWxpY2U6czNjcmV0
```

- `username`: The username.
- `password`: The password.

### token(_:)

Sets `Authorization: Token <token>`.

Used by frameworks like Django REST Framework and some CI systems.

```swift
Authorization.token(apiKey)
// -> Authorization: Token abc123
```

- `token`: The token string.

### other(_:credentials:)

Sets `Authorization: <scheme> <credentials>` for a scheme not covered
by the other factories.

```swift
Authorization.other("HOBA", credentials: "...")
// -> Authorization: HOBA ...

Authorization.other("Negotiate", credentials: negotiateToken)
// -> Authorization: Negotiate <token>
```

- `scheme`: The scheme name (e.g. `"HOBA"`, `"Negotiate"`, `"Digest"`).
- `credentials`: The credentials string written after the scheme name.

### raw(_:)

Sets the `Authorization` header to a verbatim string with no scheme
prefix.

Use this for APIs that expect an opaque key or token without a named
scheme:

```swift
Authorization.raw("my-opaque-api-key-12345")
// -> Authorization: my-opaque-api-key-12345
```

- `value`: The exact header value.

### custom(_:)

Sets the `Authorization` header via a custom authenticator closure.

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
    Header(.contentType, "application/json")
    RequestBody.json(payload)
    Authorization.custom { request in
        let body = request.httpBody ?? Data()
        let hash = SHA256.hash(data: body).description
        request.setValue("SignedHash \(hash)",
                        forHTTPHeaderField: "Authorization")
    }
}
```

- `authenticator`: A closure that inspects and mutates the
  in-progress request to apply custom authorization.

## Topics

### Factory Methods

- ``bearer(_:)``
- ``basic(username:password:)``
- ``token(_:)``
- ``other(_:credentials:)``
- ``raw(_:)``
- ``custom(_:)``
