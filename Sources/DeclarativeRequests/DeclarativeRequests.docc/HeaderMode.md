# ``HeaderMode``

Whether a header node overwrites or appends to an existing value for the same field.

## Overview

Typed headers conforming to ``SingleValueHeader`` carry a `HeaderMode`:

- ``set`` writes the value via `URLRequest.setValue(_:forHTTPHeaderField:)`, replacing any
  prior value for that field.
- ``add`` writes via `URLRequest.addValue(_:forHTTPHeaderField:)`, accumulating with any
  existing value (comma-separated on the wire).

Each typed header has a sensible default mode and exposes ``SingleValueHeader/appending()``
and ``SingleValueHeader/replacing()`` to flip between them.

## Topics

### Cases

- ``set``
- ``add``
