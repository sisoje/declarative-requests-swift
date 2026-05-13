# ``AcceptLanguageHeader``

`Accept-Language` header. Set-default.

## Overview

```swift
Headers {
    AcceptLanguageHeader(Locale.Language(identifier: "en-US"))   // en-US
}
```

Combine with ``SingleValueHeader/appending()`` and ``quality(_:)`` to build a
weighted list:

```swift
Headers {
    AcceptLanguageHeader(Locale.Language(identifier: "en-US"))
    AcceptLanguageHeader(Locale.Language(identifier: "fr")).quality(0.8).appending()
}
// Accept-Language: en-US, fr;q=0.8
```

Initialize from a `Locale.Language` (preferred) or a raw string when you need
full control over the value.

## Topics

### Creating

- ``init(_:)-(Locale.Language)``
- ``init(_:)-(String)``

### Quality

- ``quality(_:)``
