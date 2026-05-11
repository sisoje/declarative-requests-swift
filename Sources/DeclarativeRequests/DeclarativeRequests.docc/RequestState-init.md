# ``RequestState/init(request:encoder:)``

Create a new state.

- Parameters:
  - request: The starting `URLRequest`. Defaults to a request rooted at a
    placeholder URL that ``BaseURL`` is expected to replace.
  - encoder: The `JSONEncoder` used by Encodable-driven blocks.
