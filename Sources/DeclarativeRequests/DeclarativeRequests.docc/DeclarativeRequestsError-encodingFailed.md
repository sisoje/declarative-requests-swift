# ``DeclarativeRequestsError/encodingFailed(reason:)``

Encoding a model into headers, query items, or a body failed.

## Overview

Thrown when an `Encodable` value passed to ``RequestBody/json(_:)``, ``RequestBody/urlEncoded(_:)-(Encodable)``, or ``Query`` cannot be serialized by the request's ``RequestState/encoder``.

- Parameter reason: A human-readable description of what went wrong.
