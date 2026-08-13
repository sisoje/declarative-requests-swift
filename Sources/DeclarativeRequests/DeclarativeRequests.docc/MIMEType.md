# ``MIMEType``

A type-safe representation of a MIME type (media type) string.

## Overview

`MIMEType` wraps a raw string like `"application/json"` or
`"text/html; charset=utf-8"`. Use it anywhere the library expects a content type — with
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

### Namespaces

- ``Application``
- ``Text``
- ``Image``
- ``Audio``
- ``Video``
- ``Multipart``
- ``Font``

### Initializers

- ``init(rawValue:)``
- ``init(_:)``

### Raw Value

- ``rawValue``
