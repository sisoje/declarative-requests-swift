# ``MIMEType/Charset``

A character encoding identifier used with ``MIMEType/Parameter/charset(_:)-(MIMEType.Charset)``.

## Overview

Pass a `Charset` to ``MIMEType/Parameter/charset(_:)-(MIMEType.Charset)``
to produce a `charset` parameter:

```swift
let mime = MIMEType.html.with(.charset(.utf8))
// "text/html; charset=utf-8"
```

For encodings not covered by the built-in constants, create one from a
raw string:

```swift
let koi8r = MIMEType.Charset("koi8-r")
```

## Topics

### Common Charsets

- ``utf8``
- ``utf16``
- ``utf16LE``
- ``utf16BE``
- ``utf32``
- ``asciiUS``

### Legacy Charsets

- ``iso88591``
- ``iso885915``
- ``windows1252``
- ``shiftJIS``
- ``gb2312``
- ``big5``
- ``eucKR``

### Initializers

- ``init(rawValue:)``
- ``init(_:)``

### Raw Value

- ``rawValue``
