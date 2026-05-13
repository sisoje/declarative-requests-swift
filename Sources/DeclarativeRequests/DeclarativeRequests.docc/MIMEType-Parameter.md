# ``MIMEType/Parameter``

A key-value pair appended after the MIME type essence.

## Overview

Parameters appear after the semicolon in a MIME type string — for
example `charset=utf-8` in `text/html; charset=utf-8`. Use the
factory methods to build them type-safely, then attach them with
``MIMEType/with(_:)-(MIMEType.Parameter)``:

```swift
let html = MIMEType.html
    .with(.charset(.utf8))
    .with(.quality(0.9))

// "text/html; charset=utf-8; q=0.9"
```

### Custom parameters

For parameters not covered by the built-in factories, use
``custom(_:_:)``:

```swift
.with(.custom("level", "1"))
```

## Topics

### Factory Methods

- ``charset(_:)-(MIMEType.Charset)``
- ``charset(_:)-(String)``
- ``quality(_:)``
- ``boundary(_:)``
- ``version(_:)``
- ``profile(_:)``
- ``custom(_:_:)``

### Properties

- ``name``
- ``value``
- ``rawValue``

### Initializers

- ``init(name:value:)``
