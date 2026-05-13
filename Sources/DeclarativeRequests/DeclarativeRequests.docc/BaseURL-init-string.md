# ``BaseURL/init(_:)-(String)``

Create a `BaseURL` from a string.

## Overview

The string is parsed via `URL(string:)`. If parsing fails, the block throws
``DeclarativeRequestsError/badUrl`` at build time.

- Parameter string: The base URL as a string.
