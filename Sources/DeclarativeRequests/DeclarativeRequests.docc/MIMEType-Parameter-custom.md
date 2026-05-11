# ``MIMEType/Parameter/custom(_:_:)``

Creates a parameter with an arbitrary name and value.

Use this for parameters not covered by the built-in factories:

```swift
MIMEType.Application.json.with(.custom("level", "1"))
// "application/json; level=1"
```
