# ``MIMEType/Multipart``

MIME types in the `multipart` top-level type.

## Overview

Use ``formData`` for file uploads and form submissions. The
``formData(boundary:)`` convenience appends a `boundary` parameter
automatically:

```swift
MIMEType.Multipart.formData                     // "multipart/form-data"
MIMEType.Multipart.formData(boundary: "abc123") // "multipart/form-data; boundary=abc123"
```

## Topics

### Subtypes

- ``formData``
- ``mixed``
- ``alternative``
- ``related``
- ``byteranges``
- ``digest``
- ``parallel``

### Convenience

- ``formData(boundary:)``
