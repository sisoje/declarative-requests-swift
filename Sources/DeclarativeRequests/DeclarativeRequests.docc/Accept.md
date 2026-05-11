# ``Accept``

Sets the HTTP `Accept` header from a ``MIMEType``.

## Overview

Unlike ``ContentType``, multiple `Accept` blocks **accumulate** into a
single comma-separated header value — matching how browsers and API
clients negotiate content types:

```swift
let request = try URLRequest {
    Accept(.json)
    Accept(.xml.with(.quality(0.8)))
    Accept(.html.with(.quality(0.5)))
}
// Accept: application/json, application/xml; q=0.8, text/html; q=0.5
```

Quality values (`q`) are per-type, not grouped — each ``MIMEType`` carries
its own parameters.

## Topics

### Creating

- ``init(_:)``
