# Debloat TODO

Goal: lightweight machinery to get going with declarative requests.
Core stays: `RequestBuildable` + `RequestState` (one request, bindized) + result builder + blocks as thin leaves. Everything below is cutting, not adding.

Current weight: ~1700 lines in Sources, 138 docc pages, Vapor test dependency.
Benchmark: stara-verzija did all the basics in **537 lines / 22 files**. Target after debloat: ~700 (the extra ~200 buys multipart, error enum, request-property blocks, RFC 3986 endpoint resolution).

## 0. Not negotiable — the basics stay

- `Method` — GET, POST, PUT, DELETE, PATCH... + `.custom`
- `BaseURL` / `Endpoint` / `Query` (incl. `Query(encodable)`)
- `RequestBody` — `.json`, `.data`, `.string`, `.urlEncoded`, `.stream`
- `Header.x.setValue/addValue`, `Authorization` (bearer/basic/custom), `Cookie`
- `Accept` / `ContentType` blocks
- `Timeout`, `CachePolicy`, `AllowAccess`, `NetworkServiceType`, `HTTPShouldHandleCookies`
- Entry points: `URLRequest { }`, `URL.buildRequest { }`, `RequestBuilderGroup`
- Multipart field/data/file (in-memory)

Everything below cuts *duplicates and machinery*, not capability.

## 1. Kill the typed-header DSL (~270 lines, 11 files)

- [x] Delete `Blocks/Headers/` entirely: `Headers {}` + `HeadersBuilder` (a whole second result builder), `SingleValueHeader`, `HeaderMode`, `RawHeader`, and 9 typed structs (`AcceptHeader`, `ContentTypeHeader`, `UserAgentHeader`, `HostHeader`, `OriginHeader`, `RefererHeader`, `AcceptEncodingHeader`, `AcceptLanguageHeader`, `CustomHeader`)
- [x] Delete `AuthorizationHeader` — duplicate of `Authorization`
- [x] `Header.setValue/addValue` now return plain `RequestStateTransformer` (RawHeader deleted too)
- [x] Delete the corresponding tests (15) and docc pages (17)

## 2. Shrink MIMEType (~340 lines → ~40)

- [ ] Delete `MIMETypeParameter.swift` (133 lines): `.with(.quality(0.8))`, `.charset(.utf8)`, `Parameter.List`, `matches()` — content negotiation machinery nobody asked for; a raw string does it
- [ ] Reduce `MIMEType` to the stara-verzija `ContentType` model: flat raw-string constants, nothing else
- [ ] `Accept`/`ContentType` blocks stay, take `MIMEType` or raw `String`

## 3. Multipart: keep in-memory, kill streaming (~170 of 342 lines)

- [ ] Delete `.streamed()` strategy: bound-streams producer thread, buffer management, Content-Length precompute
- [ ] Keep: `MultipartPart` field/data/file + in-memory assembly + RFC 7578 escaping (that part is correct and small)
- [ ] DECIDE: or keep streaming if you actually upload big files with this

## 4. Docs surface (138 docc pages)

- [ ] Delete the per-symbol docc catalog — 138 hand-written .md pages is a maintenance millstone; doc comments in source are enough
- [ ] Keep one landing article max (`DeclarativeRequests.md`)
- [ ] Drop `swift-docc-plugin` from Package.swift if catalog goes
- [ ] Purge stale pages either way: `RequestState-subscript.md`, `HeaderCap` era leftovers

## 5. Misc cuts

- [ ] `RequestBuildable+Modifier.swift`: `environment(_:_:)` scoping trick — DECIDE keep/kill (`useEncoder` is the only real use; scoped `baseURL` doesn't survive materialization anyway)
- [ ] `URLRequest+Curl.swift` (34 lines): dev nicety — DECIDE keep/kill
- [ ] `EncodableQueryItems`: keep the feature (`Query(encodable)`) — DECIDE impl: current JSONEncoder round-trip (handles nesting/enums, needs `encoder` in state) vs stara-verzija's 20-line Mirror helper (simpler, flat structs only)
- [ ] DECIDE: restore stara-verzija builder sugar — bare `URL(string:)` / `Data` / `InputStream` expressions via `buildExpression`, so `BaseURL(...)` wrapper is optional
- [ ] Keep thin `RequestMutation` wrappers (Timeout, CachePolicy, AllowAccess, NetworkServiceType, HTTPShouldHandleCookies) — they're one-liners

## 6. Docs tell the truth (post-refactor drift)

- [ ] CLAUDE.md: "BaseURL order doesn't matter" → base is applied last (contract); "last write wins for body" → urlEncoded bodies merge
- [ ] README: same two corrections, trim removed API from the blocks table

## 7. Tests

- [ ] Vapor test target: KEEP (only thing verifying wire bytes) — but it's the whole Vapor dependency graph; revisit if resolution time hurts
- [ ] After cuts: delete tests of deleted API, run full suite, one commit per section above
