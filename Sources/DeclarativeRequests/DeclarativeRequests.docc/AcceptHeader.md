# ``AcceptHeader``

`Accept` header. Set-default — call ``HeaderBuildable/headersAdd()`` to accumulate.

## Overview

```swift
Headers {
    AcceptHeader(.json)                       // Accept: application/json
    AcceptHeader(.html).headersAdd()          // Accept: application/json,text/html
}
```

Combine with ``HeaderBuildable/headersAdd()`` and ``quality(_:)`` to build a
weighted list:

```swift
Headers {
    AcceptHeader(.json)
    AcceptHeader(.html).quality(0.8).headersAdd()
}
// Accept: application/json, text/html; q=0.8
```

Calling ``quality(_:)`` more than once replaces the previous weight rather than
stacking — per RFC 9110 §5.6.6 a parameter name appears at most once. Other
MIME parameters (e.g. `charset`) are preserved.

Initialize either from a ``MIMEType`` (preferred) or a raw string.

## Topics

### Creating

- ``init(_:)-(MIMEType)``
- ``init(_:)-(String)``

### Quality

- ``quality(_:)``
