# ``CustomHeader``

A header with a user-supplied name. **Add**-default — call ``HeaderBuildable/headersSet()`` to overwrite
instead.

## Overview

```swift
Headers {
    CustomHeader("X-Trace-Id", "abc123")          // add by default
    CustomHeader("X-Token", "new").headersSet()   // overwrites any existing X-Token
    CustomHeader("X-Tag", "a")
    CustomHeader("X-Tag", "b")                    // X-Tag: a,b
}
```

Custom headers default to additive mode because non-standard headers commonly accumulate
multiple values (e.g. tracing tags). Use ``HeaderBuildable/headersSet()`` when you need a single
canonical value.

## Topics

### Creating

- ``init(_:_:)``
