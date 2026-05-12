# ``SingleValueHeader/appending()``

Returns a copy of this header switched to ``HeaderMode/add`` mode.

## Overview

Use `appending()` to accumulate values for a header that defaults to `set`:

```swift
Headers {
    AcceptHeader(.json)                  // Accept: application/json
    AcceptHeader(.html).appending()      // Accept: application/json,text/html
}
```
