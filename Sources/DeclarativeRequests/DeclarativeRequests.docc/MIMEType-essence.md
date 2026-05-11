# ``MIMEType/essence``

The MIME type without parameters, lowercased.

Strips everything after the first semicolon and normalizes to lowercase:

```swift
let mime: MIMEType = "Text/HTML; charset=utf-8"
mime.essence // "text/html"
```
