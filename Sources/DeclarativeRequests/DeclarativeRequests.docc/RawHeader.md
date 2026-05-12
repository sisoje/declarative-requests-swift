# ``RawHeader``

Escape-hatch header node produced by ``Header/setValue(_:)`` and ``Header/addValue(_:)``.

## Overview

`RawHeader` is what the low-level ``Header`` API hands back. It conforms to
``HeaderBuildable``, so it composes inside ``Headers`` alongside the typed nodes:

```swift
Headers {
    AcceptHeader(.json)
    Header.custom("X-Trace-Id").setValue("abc123") // produces a RawHeader
}
```

Prefer the typed nodes (``AcceptHeader``, ``UserAgentHeader``, ``CustomHeader``, …) where
they exist — they read clearer and pick set/add defaults for you. Reach for `RawHeader`
when none of them fit.
