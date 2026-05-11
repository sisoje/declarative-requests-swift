# ``MIMEType``

A type-safe representation of a MIME type (media type) string.

## Overview

`MIMEType` wraps a raw string like `"application/json"` or
`"text/html; charset=utf-8"` and provides structured access to its
components. Use it anywhere the library expects a content type — with
``ContentType``, ``RequestBody``, ``MultipartPart``, or ``Header``.

### Using predefined constants

The most common MIME types are available as static properties, organized
into namespaces that mirror the MIME type registry:

```swift
MIMEType.json                       // "application/json"
MIMEType.Application.pdf            // "application/pdf"
MIMEType.Image.png                  // "image/png"
MIMEType.Text.eventStream           // "text/event-stream"
MIMEType.Multipart.formData         // "multipart/form-data"
```

Top-level shorthands like ``json``, ``html``, and ``png`` are provided
for the most frequently used types.

### Parsing components

Inspect the structure of a MIME type without manual string splitting:

```swift
let mime: MIMEType = "text/html; charset=utf-8"
mime.essence       // "text/html"
mime.type          // "text"
mime.subtype       // "html"
mime.parameters    // ["charset": "utf-8"]
```

### Adding parameters

Append parameters with ``with(_:)-swift.method`` using the type-safe
``MIMEType/Parameter`` builders:

```swift
let json = MIMEType.json
    .with(.charset(.utf8))

let multipart = MIMEType.Multipart.formData
    .with(.boundary("----Boundary123"))
```

### Comparing types

``matches(_:)`` compares two MIME types by their essence only, ignoring
parameters:

```swift
let withCharset: MIMEType = "application/json; charset=utf-8"
withCharset.matches(.json) // true
```

### Custom MIME types

Create a MIME type from any raw string — either through the initializer
or a string literal:

```swift
let custom = MIMEType("application/vnd.myapp+json")
let literal: MIMEType = "application/vnd.myapp+json"
```

## Topics

### Convenience Constants

- ``json``
- ``xml``
- ``html``
- ``plainText``
- ``formURLEncoded``
- ``octetStream``
- ``pdf``
- ``png``
- ``jpeg``

### Parsing

- ``essence``
- ``type``
- ``subtype``
- ``parameters``
- ``matches(_:)``

### Composing

- ``with(_:)-4lb08``
- ``with(_:)-7nt2l``
- ``with(_:)-7egqw``

### Namespaces

- ``Application``
- ``Text``
- ``Image``
- ``Audio``
- ``Video``
- ``Multipart``
- ``Font``

### Nested Types

- ``Parameter``
- ``Charset``

### Initializers

- ``init(rawValue:)``
- ``init(_:)``

### Raw Value

- ``rawValue``
