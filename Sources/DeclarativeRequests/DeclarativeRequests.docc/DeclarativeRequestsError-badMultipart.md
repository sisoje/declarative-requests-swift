# ``DeclarativeRequestsError/badMultipart(reason:)``

A ``RequestBody/multipart(boundary:strategy:_:)`` block could not be assembled.

## Overview

Most often thrown because a ``MultipartPart/file(name:fileURL:type:filename:)`` part references a path that cannot be read, or the bound streams could not be created for the streamed strategy.

- Parameter reason: A human-readable description of what went wrong.
