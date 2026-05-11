# ``Query``

Appends one or more query items to the request URL.

## Overview

`Query` lets you declare a single name/value pair or pass an `Encodable`
model that flattens to a list of items.

```swift
// Single item:
Query("page", "2")

// Multiple items via repeated declarations:
Query("filter", "active")
Query("filter", "new")

// From an Encodable model:
struct UsersFilter: Codable { let page: Int; let pageSize: Int }
Query(UsersFilter(page: 2, pageSize: 50))
```

Items are appended (not deduplicated), so multiple declarations with the
same name produce multiple `?name=...&name=...` entries. Encodable models are
serialized with the request's ``RequestState/encoder`` and then flattened via
`JSONSerialization`; nested arrays are represented with bracket-indexed
keys (`tags[0]=a&tags[1]=b`).

### init(_ name: String, _ value: String?)

Append a single query item.

- Parameters:
  - name: The query item name.
  - value: The query item value, or `nil` to emit `?name`.

### init(_ encodable: any Encodable)

Append items derived from an `Encodable` model.

Top-level fields become query item names. Nested arrays produce
bracket-indexed keys; nested dictionaries are flattened with their
nested keys becoming the names. Booleans serialize as `"true"`/`"false"`.

- Parameter encodable: The model to encode.

## Topics

### Creating a Query
- ``init(_:_:)``
- ``init(_:)-1ctm6``

### Composing

- ``body``
- ``request``
