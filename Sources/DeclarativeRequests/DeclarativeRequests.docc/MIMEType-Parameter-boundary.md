# ``MIMEType/Parameter/boundary(_:)``

Creates a `boundary` parameter, typically used with multipart types.

```swift
MIMEType.Multipart.formData.with(.boundary("----Boundary123"))
// "multipart/form-data; boundary=----Boundary123"
```
