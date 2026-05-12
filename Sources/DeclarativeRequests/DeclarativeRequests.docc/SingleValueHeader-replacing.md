# ``SingleValueHeader/replacing()``

Returns a copy of this header switched to ``HeaderMode/set`` mode.

## Overview

Use `replacing()` to overwrite an existing value when the header defaults to `add` — for
example, to replace any previously-set custom header:

```swift
Headers {
    CustomHeader("X-Token", "old")            // add by default
    CustomHeader("X-Token", "new").replacing() // overwrites → X-Token: new
}
```
