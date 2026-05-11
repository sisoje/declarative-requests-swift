# ``MIMEType/Parameter/quality(_:)``

Creates a `q` (quality factor) parameter.

The value is clamped to `0...1` and formatted with minimal trailing
zeros:

```swift
MIMEType.html.with(.quality(0.9))
// "text/html; q=0.9"
```
