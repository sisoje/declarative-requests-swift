# ``HeaderBuildable``

Marker protocol for any node ``Headers`` accepts.

## Overview

Every header node shipped by the library conforms to `HeaderBuildable`:
``RawHeader``, ``AcceptHeader``, ``ContentTypeHeader``, ``UserAgentHeader``,
``AuthorizationHeader``'s factory return type, ``HostHeader``, ``OriginHeader``,
``RefererHeader``, ``AcceptLanguageHeader``, ``AcceptEncodingHeader``, and
``CustomHeader``.

Conform your own types to `HeaderBuildable` to make them usable inside ``Headers``.
Since the protocol refines ``RequestBuildable``, any header node also remains usable at
the top level of a ``RequestBuilder`` closure.

```swift
struct CorrelationHeader: HeaderBuildable {
    let id: UUID
    var body: some RequestBuildable {
        Header.custom("X-Correlation-Id").setValue(id.uuidString)
    }
}

Headers {
    CorrelationHeader(id: .init())
}
```
