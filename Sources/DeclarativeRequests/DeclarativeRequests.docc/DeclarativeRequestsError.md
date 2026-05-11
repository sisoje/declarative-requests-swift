# ``DeclarativeRequestsError``

Errors thrown while building a request through the DSL.

## Overview

All cases conform to `LocalizedError` so they produce a useful
`localizedDescription` when surfaced to users or logged.

### badUrl

The request URL is missing or could not be constructed from the inputs
declared in the builder.

Typically thrown by ``BaseURL`` when given an invalid string, or by
``Endpoint`` when no base URL has been set.

### badStream

A ``RequestBody/stream(_:)`` block could not produce or open its `InputStream`.

### badMultipart(reason:)

A ``RequestBody/multipart(boundary:strategy:_:)`` block could not be
assembled — most often because a
``MultipartPart/file(name:fileURL:type:filename:)`` part references a
path that cannot be read.

- Parameter reason: A human-readable description of what went wrong.

### encodingFailed(reason:)

Encoding a model into headers, query items, or a body failed.

- Parameter reason: A human-readable description of what went wrong.

### errorDescription

A localized, human-readable description of the error suitable for
surfacing to end users or writing to logs.

## Topics

### Error Cases

- ``badUrl``
- ``badStream``
- ``badMultipart(reason:)``
- ``encodingFailed(reason:)``

### Instance Properties

- ``errorDescription``

### Equatable Implementations

- ``!=(_:_:)``

### Error Implementations

- ``localizedDescription``

### LocalizedError Implementations

- ``errorDescription``
- ``failureReason``
- ``helpAnchor``
- ``recoverySuggestion``
