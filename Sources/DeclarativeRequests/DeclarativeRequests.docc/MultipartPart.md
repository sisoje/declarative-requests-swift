# ``MultipartPart``

A single piece of a `multipart/form-data` payload.

## Overview

Use the case constructors inside a ``RequestBody/multipart(boundary:strategy:_:)``
block:

```swift
RequestBody.multipart {
    MultipartPart.field(name: "user", value: "alice")
    MultipartPart.data(name: "avatar", filename: "a.png", data: pngBytes, type: .PNG)
    MultipartPart.file(name: "doc", fileURL: localFile, type: .PDF)
}
```

### field(name:value:)

A simple text field -- the multipart equivalent of an HTML
`<input type="text">`.

### data(name:filename:data:type:)

A file part backed by an in-memory `Data` blob.

### file(name:fileURL:type:filename:)

A file part loaded from disk (or streamed, depending on strategy).

## Topics

### Part Cases

- ``field(name:value:)``
- ``data(name:filename:data:type:)``
- ``file(name:fileURL:type:filename:)``
