# ``MIMEType/subtype``

The subtype component (e.g. `"json"`, `"html"`, `"png"`).

Extracted from ``essence`` by splitting on `/`:

```swift
let mime: MIMEType = "application/json"
mime.subtype // "json"
```

Returns `nil` if the string contains no `/`.
