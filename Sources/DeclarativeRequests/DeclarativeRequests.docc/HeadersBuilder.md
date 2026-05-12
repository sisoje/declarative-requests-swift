# ``HeadersBuilder``

Result builder used by ``Headers`` — accepts only ``HeaderBuildable`` values.

## Overview

`HeadersBuilder` collects header nodes declared inside a ``Headers`` closure and reduces
them into a single transform. Non-``HeaderBuildable`` expressions are rejected at
compile time:

```swift
Headers {
    AcceptHeader(.json)       // OK — HeaderBuildable
    UserAgentHeader("DR/1.0") // OK — HeaderBuildable
    Method.GET                // compile error — not a header
}
```

Standard control-flow inside the builder works: `if`, `if/else`, `switch`, `for`, and
`if #available`.
