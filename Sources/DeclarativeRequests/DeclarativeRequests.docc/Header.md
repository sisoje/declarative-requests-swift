# ``Header``

A typed identifier for standard and custom HTTP header fields.

## Overview

`Header` provides type-safe access to commonly used HTTP headers and a
``custom(_:)`` escape hatch for anything not covered by the built-in
cases. Each case maps to its canonical wire name through ``rawValue``
(e.g. `.acceptLanguage` becomes `"Accept-Language"`).

Use ``setValue(_:)`` to set a header, replacing any previous value for
that field, or ``addValue(_:)`` to append a value without removing
existing ones (useful for multi-value headers like `Cookie`):

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/users")
    Header(.accept, "application/json")          // sugar -- see below
    Header.authorization.setValue("Bearer tok")
    Header.custom("X-Request-ID").setValue("42")
}
```

Both ``setValue(_:)`` and ``addValue(_:)`` return opaque
``RequestBuildable`` values, so they compose naturally inside a
`@RequestBuilder` closure:

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Header.accept.setValue("application/json")
    Header.acceptLanguage.setValue("en-US")
    Header.cookie.addValue("session=abc")
    Header.cookie.addValue("prefs=dark")
}
```

### setValue(_:)

Sets the header to the given value, replacing any previous value for
that field. This maps to `URLRequest.setValue(_:forHTTPHeaderField:)`.

- Parameter value: The header value.
- Returns: A ``RequestBuildable`` block that applies the header.

### addValue(_:)

Appends the given value to the header without removing existing values.
This maps to `URLRequest.addValue(_:forHTTPHeaderField:)`, which is
the correct choice for headers that accept comma-separated lists (e.g.
`Cookie`, `Accept`).

- Parameter value: The header value to add.
- Returns: A ``RequestBuildable`` block that applies the header.

### custom(_:)

Use a non-standard header field name.

The string is written verbatim as the header field name, so make sure
it matches the casing the server expects.

- Parameter name: The header field name.

## Topics

### Standard Headers

- ``contentType``
- ``accept``
- ``authorization``
- ``userAgent``
- ``origin``
- ``cookie``
- ``referer``
- ``host``
- ``acceptLanguage``
- ``acceptEncoding``

### Custom Headers

- ``custom(_:)``

### Setting Values

- ``setValue(_:)``
- ``addValue(_:)``

### Raw Value

- ``rawValue``
