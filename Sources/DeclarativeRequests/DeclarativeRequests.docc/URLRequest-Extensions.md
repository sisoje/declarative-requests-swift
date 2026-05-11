# ``Foundation/URLRequest``

Convenience extensions for building and inspecting requests with the declarative DSL.

@Metadata {
    @DisplayName("URLRequest Extensions")
}

## Overview

DeclarativeRequests adds two convenience members to `URLRequest` so you can
go from zero to a fully configured request — or from a request to a
debuggable shell command — without leaving Foundation's type system.

### Building a request from scratch

The ``init(builder:)`` initializer is the primary entry point when you
don't already have a `URL` value. Declare the URL inside the builder with
``BaseURL`` and layer on method, headers, and body:

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/v1/users")
    Authorization.bearer(token)
    RequestBody.json(CreateUserRequest(name: "Alice"))
}
```

This is a convenience wrapper around ``RequestBlock/init(builder:)`` and
``RequestBuildable/request`` — it creates a ``RequestState``, applies every
block in declaration order, and returns the finished `URLRequest`.

### Inspecting the wire format

The ``curlCommand`` property produces a copy-pasteable `curl` invocation
equivalent to the request. Use it for debugging, logging, or pasting into
bug reports:

```swift
print(request.curlCommand)
// curl -X POST -H 'Authorization: Bearer ...' -H 'Content-Type: application/json'
//   --data-binary '{"name":"Alice"}' 'https://api.example.com/v1/users'
```

Values are single-quoted so shell metacharacters survive a copy-paste.
`GET` is the implicit curl default and is omitted for brevity. Non-UTF-8
bodies are noted as a comment with the byte count rather than dumped raw.

## Topics

### Building a Request

- ``init(builder:)``

### Debugging

- ``curlCommand``
