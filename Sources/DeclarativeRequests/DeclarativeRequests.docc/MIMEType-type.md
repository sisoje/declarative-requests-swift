# ``MIMEType/type``

The top-level type component (e.g. `"application"`, `"text"`, `"image"`).

Extracted from ``essence`` by splitting on `/`:

```swift
let mime: MIMEType = "application/json"
mime.type // "application"
```

Returns `nil` if the string contains no `/`.
