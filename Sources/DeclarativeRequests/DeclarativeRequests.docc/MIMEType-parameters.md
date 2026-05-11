# ``MIMEType/parameters``

The semicolon-delimited parameters as a dictionary.

Keys are lowercased; values preserve their original casing:

```swift
let mime: MIMEType = "text/html; charset=utf-8; q=0.9"
mime.parameters // ["charset": "utf-8", "q": "0.9"]
```
