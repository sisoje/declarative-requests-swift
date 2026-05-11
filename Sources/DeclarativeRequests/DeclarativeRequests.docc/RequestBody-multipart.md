# ``RequestBody/multipart(boundary:strategy:_:)``

A `multipart/form-data` body assembled from the supplied parts.

## Overview

```swift
RequestBody.multipart {
    MultipartPart.field(name: "user", value: "alice")
    MultipartPart.data(name: "avatar", filename: "a.png", data: png, type: .png)
    for url in fileURLs {
        MultipartPart.file(name: "files", fileURL: url, type: .octetStream)
    }
}
```

Sets `Content-Type: multipart/form-data; boundary=...`. With
``RequestBody/MultipartStrategy/streamed(bufferSize:)`` it also sets
`Content-Length` and `httpBodyStream` instead of `httpBody`.

- `boundary`: The multipart boundary token. Defaults to a random
  `Boundary-<UUID>` value.
- `strategy`: Whether to assemble in memory (default) or stream from
  disk for very large payloads.
- `parts`: A `@MultipartBuilder` closure that produces the parts.
