# ``ContentTypeHeader``

`Content-Type` header. Set-default.

## Overview

```swift
Headers {
    ContentTypeHeader(.json)         // Content-Type: application/json
    ContentTypeHeader("text/csv")    // Content-Type: text/csv
}
```

Initialize either from a ``MIMEType`` (preferred) or a raw string.

## Topics

### Creating

- ``init(_:)-(MIMEType)``
- ``init(_:)-(String)``
