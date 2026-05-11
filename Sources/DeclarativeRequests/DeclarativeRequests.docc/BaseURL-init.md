# ``BaseURL/init(_:)``

Create a `BaseURL` from a `URL` value or a string.

## Overview

Two overloads are available:

- `init(_ url: URL?)` accepts a `URL` value. Passing `nil` produces a block
  that throws ``DeclarativeRequestsError/badUrl`` at build time.
- `init(_ string: String)` parses the string via `URL(string:)`. If the
  string is not a valid URL, the block throws
  ``DeclarativeRequestsError/badUrl`` at build time.
