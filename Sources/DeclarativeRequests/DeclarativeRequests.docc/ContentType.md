# ``ContentType``

Sets the HTTP `Content-Type` header from a ``MIMEType``.

## Overview

Use `ContentType` as a block to set the `Content-Type` header, or pass it
as a parameter to body blocks like ``RequestBody`` and ``MultipartPart``:

```swift
// As a block — pass any MIMEType:
ContentType(.json)  // sets Content-Type: application/json

// With parameters:
ContentType(.json.with(.charset(.utf8)))
// sets Content-Type: application/json; charset=utf-8
```

`ContentType` follows **last-write-wins** semantics — declaring it
multiple times replaces the previous value. MIME type constants come
from ``MIMEType`` directly — `ContentType` has no constants of its own.

## Topics

### Creating

- ``init(_:)``
- ``mimeType``
