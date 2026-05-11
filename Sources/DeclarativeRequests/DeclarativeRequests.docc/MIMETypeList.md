# ``MIMETypeList``

An ordered collection of MIME types, typically used for `Accept` headers.

## Overview

`MIMETypeList` formats multiple ``MIMEType`` values into a
comma-separated string suitable for HTTP headers like `Accept`:

```swift
let accept = MIMETypeList(.json, .xml)
accept.rawValue // "application/json, application/xml"
```

It conforms to `ExpressibleByArrayLiteral`, so you can use array syntax
wherever a `MIMETypeList` is expected:

```swift
let types: MIMETypeList = [.json, .html, .xml]
```

## Topics

### Initializers

- ``init(_:)-2b1mf``
- ``init(_:)-61oau``

### Properties

- ``items``
- ``rawValue``
