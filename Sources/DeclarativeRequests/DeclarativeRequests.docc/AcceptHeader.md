# ``AcceptHeader``

`Accept` header. Set-default — call ``SingleValueHeader/appending()`` to accumulate.

## Overview

```swift
Headers {
    AcceptHeader(.json)                  // Accept: application/json
    AcceptHeader(.html).appending()      // Accept: application/json,text/html
}
```

Initialize either from a ``MIMEType`` (preferred) or a raw string.

## Topics

### Creating

- ``init(_:)-(MIMEType)``
- ``init(_:)-(String)``
