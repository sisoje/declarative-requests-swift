# ``RequestBody``

The HTTP request body -- one block, several factories.

## Overview

`RequestBody` is the single block for everything that goes after the empty line
in a raw HTTP request. The factory you pick decides how the bytes are
produced and what `Content-Type` (if any) is set on the request:

```swift
// Raw bytes (or string) with optional Content-Type:
RequestBody.data(jpegData, type: .JPEG)
RequestBody.string("hello")                              // text/plain

// Encodable -> JSON, sets Content-Type: application/json
RequestBody.json(LoginRequest(email: e, password: p))

// application/x-www-form-urlencoded
RequestBody.urlEncoded([
    URLQueryItem(name: "grant_type", value: "password"),
    URLQueryItem(name: "username", value: "alice"),
])
RequestBody.urlEncoded(loginForm)                        // any Encodable / [String:String]

// Stream the body from an InputStream:
RequestBody.stream(InputStream(url: largeFileURL))

// multipart/form-data:
RequestBody.multipart {
    MultipartPart.field(name: "title", value: "Vacation")
    MultipartPart.file(name: "video", fileURL: clipURL, type: .Video.mp4)
}
// ...or streaming for huge files:
RequestBody.multipart(strategy: .streamed()) { ... }
```

Like every other request property, the body is *replaced* if multiple
`RequestBody.*` blocks are declared -- the last one wins.

### data(_:type:)

A `Data` body, optionally tagged with a `Content-Type`.

- `data`: The body bytes.
- `type`: The content type to set on the request, or `nil` to leave any
  existing `Content-Type` untouched.

### string(_:type:)

A UTF-8 string body. Defaults to `Content-Type: text/plain`.

- `string`: The body text.
- `type`: The MIME type to set. Defaults to ``MIMEType/plainText``.

### json(_:)

JSON-encodes `value` into the body and sets `Content-Type: application/json`.

Uses the request's ``RequestState/encoder``, so any encoder configuration
(date strategy, key strategy, output formatting) you set there is applied.

- `value`: The value to encode.

### urlEncoded(_:) -- URLQueryItem array

A `application/x-www-form-urlencoded` body built from explicit query items.

Items are encoded in the supplied order; duplicate names are preserved
(`a=1&a=2&b=3`).

- `items`: The form items to encode.

### urlEncoded(_:) -- Encodable

A `application/x-www-form-urlencoded` body built from an `Encodable` model.

Top-level fields become form items. Nested arrays use bracket-indexed
keys (`tags[0]=a&tags[1]=b`). Booleans serialize as `"true"`/`"false"`.
Dictionary keys are emitted in alphabetical order so the body is
deterministic.

`[String: String]` literals also satisfy `Encodable`, so this overload
covers the common dict case:

```swift
RequestBody.urlEncoded(["grant_type": "password", "username": "alice"])
```

- `encodable`: The model to encode.

### stream(_:)

Stream the body from an `InputStream`. Sets `httpBodyStream`.

The stream factory is `@autoclosure`, so the actual `InputStream`
instance is lazily produced when the block is applied -- important
because a stream is single-use; if the request is built more than once,
each build needs its own stream.

```swift
RequestBody.stream(InputStream(url: largeFileURL))
```

Note: this does *not* set `Content-Type` -- pair it with a `Header(...)`
declaration if the server needs one.

- `stream`: An autoclosure that produces an `InputStream`. If it
  returns `nil`, the block throws ``DeclarativeRequestsError/badStream``
  when applied.

## Topics

### Factory Methods

- ``data(_:type:)``
- ``string(_:type:)``
- ``json(_:)``
- ``urlEncoded(_:)-3uhox``
- ``urlEncoded(_:)-5ko3k``
- ``stream(_:)``
- ``multipart(boundary:strategy:_:)``
