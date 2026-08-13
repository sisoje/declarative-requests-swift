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

- [x] Delete `MIMETypeParameter.swift` (133 lines): `.with(.quality(0.8))`, `.charset(.utf8)`, `Parameter.List`, `matches()` — content negotiation machinery nobody asked for; a raw string does it
- [x] Reduce `MIMEType` to the stara-verzija `ContentType` model: flat raw-string constants, nothing else (also dropped Codable/essence/type/subtype/parameters)
- [x] `Accept`/`ContentType` blocks stay, take `MIMEType` or string literal (`Accept("application/xml; q=0.8")`)

## 3. Multipart: keep in-memory, kill streaming (~170 of 342 lines)

- [x] Delete `.streamed()` strategy: bound-streams producer thread, buffer management, Content-Length precompute (also: couldn't replay body on redirect/auth, leaked producer thread on unsent requests)
- [x] Keep: `MultipartPart` field/data/file + in-memory assembly + RFC 7578 escaping (125 lines now)

## 4. Docs surface (138 docc pages)

- [x] Delete the per-symbol docc catalog — doc comments in source are enough
- [x] Keep one landing article max (`DeclarativeRequests.md`)
- [x] Drop `swift-docc-plugin` from Package.swift

## 5. Misc cuts

- [x] `environment(_:_:)` scoping trick killed; `useEncoder` stays as a plain setter block
- [x] `URLRequest+Curl.swift` deleted — debugging nicety, separate-package territory
- [x] `EncodableQueryItems` kept as is (JSONEncoder round-trip — handles enums/nesting, powers urlEncoded(encodable))
- [x] Bare-expression sugar NOT restored — one obvious spelling per capability
- [x] Keep thin `RequestMutation` wrappers (Timeout, CachePolicy, AllowAccess, NetworkServiceType, HTTPShouldHandleCookies) — they're one-liners

## 6. Docs tell the truth (post-refactor drift)

- [x] CLAUDE.md: base-last contract, urlEncoded merge, scope rules section added
- [x] README: same corrections, removed API purged

## 7. Tests

- [x] Vapor test target: KEEP (only thing verifying wire bytes) — but it's the whole Vapor dependency graph; revisit if resolution time hurts
- [x] After cuts: deleted tests of deleted API, full suite green, one commit per section

## Done beyond plan

- [x] MIMEType flattened to 8 constants (json/xml/html/plainText/formURLEncoded/octetStream/png/jpeg) — everything else is a string literal
- [x] DeclarativeRequestsError: bare enum, no LocalizedError prose, unthrown encodingFailed case deleted

Progress: 1689 → ~760 source lines.
