# ``Query/init(_:)``

Append items derived from an `Encodable` model.

## Overview

Top-level fields become query item names. Nested arrays produce
bracket-indexed keys (`tags[0]=a&tags[1]=b`). Booleans serialize as
`"true"`/`"false"`. The model is encoded with the request's
``RequestState/encoder``.

- Parameter encodable: The model to encode.
