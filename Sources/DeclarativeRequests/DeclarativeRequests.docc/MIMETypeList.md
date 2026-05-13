# ``MIMEType/List``

An ordered collection of MIME types, typically used for `Accept` headers.

## Overview

`MIMEType.List` formats multiple ``MIMEType`` values into a
comma-separated string suitable for HTTP headers like `Accept`:

```swift
let accept = MIMEType.List(.json, .xml)
accept.rawValue // "application/json, application/xml"
```

It conforms to `ExpressibleByArrayLiteral`, so you can use array syntax
wherever a `MIMEType.List` is expected:

```swift
let types: MIMEType.List = [.json, .html, .xml]
```

## Topics

### Initializers

- ``init(_:)-([MIMEType])``
- ``init(_:)-(MIMEType...)``

### Properties

- ``items``
- ``rawValue``
