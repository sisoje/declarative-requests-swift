# ``RequestBody/string(_:type:)``

A UTF-8 string body. Defaults to `Content-Type: text/plain`.

## Overview

```swift
RequestBody.string("hello")
// Content-Type: text/plain

RequestBody.string("<html>hi</html>", type: .html)
// Content-Type: text/html
```

- Parameters:
  - string: The body text.
  - type: The MIME type to set. Defaults to ``MIMEType/plainText``.
