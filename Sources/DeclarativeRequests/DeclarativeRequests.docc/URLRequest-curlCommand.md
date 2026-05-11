# ``Foundation/URLRequest/curlCommand``

A copy-pasteable `curl` command equivalent of this request.

## Overview

Useful for debugging, reproducing failures from a terminal, and pasting into
bug reports. The output is single-quoted so values containing shell
metacharacters survive a copy-paste; embedded single quotes are escaped via
the standard `'\''` trick.

```swift
let request = try URLRequest {
    Method.POST
    BaseURL("https://api.example.com")
    Endpoint("/login")
    Header.accept.setValue("application/json")
    RequestBody.string("{\"user\":\"alice\"}", type: .json)
}
print(request.curlCommand)
// curl -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' \
//   --data-binary '{"user":"alice"}' 'https://api.example.com/login'
```

> Note: `GET` is the implicit default and is omitted from the output. Bodies that
> aren't valid UTF-8 are noted as a comment with the byte count rather than
> dumped raw.
