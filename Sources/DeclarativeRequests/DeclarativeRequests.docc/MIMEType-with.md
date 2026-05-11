# ``MIMEType/with(_:)-4lb08``

Appends a ``MIMEType/Parameter`` to the MIME type string.

Each call adds `; name=value` to the raw value:

```swift
let mime = MIMEType.json
    .with(.charset(.utf8))
    .with(.quality(0.9))

mime.rawValue // "application/json; charset=utf-8; q=0.9"
```

Use the variadic or array overloads to attach several parameters at once.
