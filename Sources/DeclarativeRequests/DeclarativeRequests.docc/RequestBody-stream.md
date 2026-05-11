# ``RequestBody/stream(_:)``

Stream the body from an `InputStream`. Sets `httpBodyStream`.

## Overview

The stream factory is `@autoclosure`, so the actual `InputStream`
instance is lazily produced when the block is applied -- important
because a stream is single-use; if the request is built more than once,
each build needs its own stream.

This does *not* set `Content-Type` -- pair it with a ``Header`` block
if the server needs one.

```swift
RequestBody.stream(InputStream(url: largeFileURL))
```

Throws ``DeclarativeRequestsError/badStream`` if the autoclosure
returns `nil`.

- Parameters:
  - stream: An autoclosure that produces an `InputStream`.
