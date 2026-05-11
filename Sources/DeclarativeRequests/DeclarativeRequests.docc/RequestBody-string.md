# ``RequestBody/string(_:type:)``

A UTF-8 string body. Defaults to `Content-Type: text/plain`.

## Overview

```swift
RequestBody.string("hello")
// Content-Type: text/plain

RequestBody.string("<html>hi</html>", type: .HTML)
// Content-Type: text/html
```

- Parameters:
  - string: The body text.
  - type: The content type to set. Defaults to ``ContentType/PlainText``.
