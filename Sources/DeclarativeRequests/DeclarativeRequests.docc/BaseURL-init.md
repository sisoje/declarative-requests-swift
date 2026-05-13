# ``BaseURL/init(_:)-(URL?)``

Create a `BaseURL` from a `URL` value.

## Overview

Passing `nil` produces a block that throws ``DeclarativeRequestsError/badUrl``
at build time — useful when you're computing a URL from an optional and want
the failure to surface as a thrown error rather than a crash.

- Parameter url: The base URL, or `nil` to throw at build time.
