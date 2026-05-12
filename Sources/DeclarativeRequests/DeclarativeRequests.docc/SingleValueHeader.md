# ``SingleValueHeader``

Shared shape for typed headers that carry a single string value bound to a fixed
``Header`` name.

## Overview

Every set-default typed header (``AcceptHeader``, ``ContentTypeHeader``,
``UserAgentHeader``, ``HostHeader``, ``OriginHeader``, ``RefererHeader``,
``AcceptLanguageHeader``, ``AcceptEncodingHeader``) adopts `SingleValueHeader`.
Conformers get ``appending()`` and ``replacing()`` for free, plus a default `body`
implementation that picks `URLRequest.setValue` or `URLRequest.addValue` based on
``HeaderMode``.

Conform your own types to `SingleValueHeader` to define additional canonical headers
without writing boilerplate:

```swift
struct DNTHeader: SingleValueHeader {
    static var headerName: Header { .custom("DNT") }
    var value: String
    var mode: HeaderMode
    init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }
    init(_ enabled: Bool) {
        self.init(value: enabled ? "1" : "0", mode: .set)
    }
}
```

## Topics

### Modifiers

- ``appending()``
- ``replacing()``
