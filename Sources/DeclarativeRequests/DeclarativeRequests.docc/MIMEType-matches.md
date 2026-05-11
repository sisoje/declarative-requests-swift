# ``MIMEType/matches(_:)``

Compares two MIME types by essence only, ignoring parameters.

```swift
let withParams: MIMEType = "application/json; charset=utf-8"
withParams.matches(.json) // true — both have essence "application/json"
```
