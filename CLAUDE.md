# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package scope — what belongs, what doesn't

This is deliberately a **lightweight** package: declarative machinery to compose a `URLRequest`, nothing else.

**Belongs:**
- The core machinery: the result builder, `RequestBuildable` recursion, `RequestState` (one `URLRequest`, everything else a projection into it), `RequestMutation`.
- Thin blocks mapping 1:1 onto pieces of a raw HTTP request or `URLRequest` properties — method, URL parts, headers, cookies, body, networking knobs. **One obvious spelling per capability.**
- Basic body encoders: JSON, url-encoded form, string/data/stream, in-memory multipart.

**Does not belong** (belongs in a separate package, if anywhere):
- Sugar that duplicates an existing spelling (the typed-header structs and `Headers {}` DSL were removed for this).
- Content-negotiation machinery (the MIME parameter algebra was removed; parameters are string literals: `Header.accept.addValue("application/xml; q=0.8")`).
- Transport machinery (streamed multipart with its producer thread was removed; for huge uploads write the assembled body to a temp file and use `URLSession.uploadTask(fromFile:)`).
- `import SwiftUI`/Combine, `@Observable`, or speculative `Sendable` annotations.
- Code defending against idiotic usage. Contracts are documented, not enforced with extra machinery.

**We do not write code for idiots.** Documented limitations are part of the API contract, and users are expected to accept them — `BaseURL` comes last (or at least after the path), and that's ok. We don't add code so that every ordering or misuse works anyway:
- No defensive re-mutation or re-assignment — state is written once, honestly; no getter that recomputes what a setter already wrote, no setter that resets what someone else assigned (both existed once; both were bugs).
- No checking every stupid error. A composition outside the contract produces a wrong request, not a babysitting throw — users **verify their builders in tests**. A request builder is pure and trivially testable; an untested builder is the user's bug, not this package's.
- Validation added "for safety" is scope creep with an if-statement. Reject it in review.

**Rules of thumb:** a new block should be a one-liner over `RequestState`/`RequestMutation`. If a feature needs its own thread, run loop, or a second way of building *requests*, it does not go in this package (the multipart part-list builder is fine — it builds parts, not requests). When in doubt, the original version of this library (branch `stara-verzija`) did everything essential in ~540 lines — that is the spirit level.

## Build & test

Swift Package Manager project (swift-tools-version 6.3, no Xcode project file, zero dependencies).

```sh
swift build
swift test                                          # all tests
swift test --filter <TestName>                      # single test by @Test function name
```

CI runs plain `swift test` on macos-latest with an SPM `.build` cache (see `.github/workflows/swift.yml`).

Tests use **swift-testing** (`import Testing`, `@Test`), not XCTest.

## Architecture

The DSL is a SwiftUI-style result builder for `URLRequest`. Five core pieces make the whole thing work:

- **`RequestBuildable`** (protocol, `Sources/DeclarativeRequests/RequestBuildable.swift`) — every block conforms. Has an associated `Body: RequestBuildable` so blocks compose recursively the way SwiftUI views do.
- **`RequestBlock`** (`Blocks/RequestBlock.swift`) — the leaf. Wraps a `RequestStateTransformClosure` directly; its `body` is unreachable (traps if called). All other blocks ultimately reduce to this.
- **`RequestState`** (`RequestState.swift`) — the mutable context threaded through every block during a build. Stores exactly one `URLRequest` (the source of truth) plus the `JSONEncoder` used by `Encodable`-driven blocks. `baseURL`, `urlComponents`, `cookies`, and `encodedBodyItems` are computed projections that read and write through the request — never add stored side-state next to it.
- **`RequestBuilder`** (`RequestBuilder.swift`) — the `@resultBuilder`. Folds the listed blocks into a single composed transform applied left-to-right (top-to-bottom). Supports `if`/`if-else`/`switch`/`for`/`if #available`. Non-`RequestBuildable` expressions are rejected at compile time via an `@available(*, unavailable)` `buildExpression` overload.
- **`RequestStateTransformClosure`** = `(RequestState) throws -> Void`. The inner currency.

The recursion termination trick: `RequestBuildable.transform` checks `if let leaf = self as? RequestBlock` and returns the closure directly; otherwise it recurses into `body.transform`. So custom blocks just return composed sub-blocks from `body` — no boilerplate.

### How a build flows

`URLRequest(builder:)`, `URL.buildRequest`, and `RequestBuildable.request` all do the same thing:

1. Create a `RequestState` (placeholder URL: `URLComponents().url!`).
2. Call `transform(state)` — which recurses through every block's `body` and applies each leaf closure in declaration order.
3. Return `state.request`.

### Block conventions

- **`BaseURL` is applied last.** That is the contract — `URL.buildRequest` appends it after the builder blocks automatically. The relative-URL projections happen to tolerate base-first ordering, but it is not guaranteed and not to be defended with extra code or tests.
- **Last write wins** for properties (method, URL, body) — with one deliberate exception: `RequestBody.urlEncoded` *merges* its items into an existing form body. Accumulating blocks (cookies, query items, `Header.x.addValue`) read-then-write the existing value.
- **`Endpoint`** just sets `urlComponents.path` (replacing any previous path). Resolution against the base happens via Foundation's relative-URL rules when the URL is rebuilt: leading `/` is from the root, a bare segment is relative to the base directory.
- **`RequestMutation[\.keyPath, value]` subscript** is the canonical way to write a one-line block (used by `Method`, `Timeout`, `AllowAccess`, etc.). New blocks should use it instead of writing closures by hand.
- **A block that merely restates one keypath gets deleted** — enum-typed and bare-Bool `URLRequest` properties are spelled `RequestMutation[\.cachePolicy, .returnCacheDataElseLoad]`, `RequestMutation[\.httpShouldHandleCookies, false]`; type inference gives leading-dot cases for free (CachePolicy, NetworkServiceType, and HTTPShouldHandleCookies existed once; all deleted). A named block must add something a keypath can't: a rawValue mapping (`Method`), composition (`BaseURL`/`Endpoint`), merging (`Cookie`), or encoding (`RequestBody`).
- **Encodable-driven blocks** (`Query(_:)`, `Cookie(_:)`, `RequestBody.json/.urlEncoded`) route through `state.encoder` so the user's encoder configuration (date strategy, key strategy) is respected.
- **`MIMEType`** cases are nodes, Header-style: `MIMEType.json.contentType` (set) / `MIMEType.json.accept` (add). Arbitrary values go through `Header.contentType/.accept` directly.
- **`RequestBody.stream(_:)`** takes an `@autoclosure` so the `InputStream` is recreated on each build (streams are single-use).
- **Multipart** is in-memory only (`RequestBody.multipart` assembles a `Data` blob per RFC 7578). See `RequestBody+Multipart.swift`.

## Tests

`Tests/DeclarativeRequestsTests/` — pure unit tests, no network, asserting each block produces the expected `URLRequest` shape (including exact multipart body bytes). The library has **zero dependencies** beyond `Foundation` — keep it that way, test-target included.

## House style

- No `Sendable` / `@unchecked Sendable` annotations unless explicitly required. Concurrency is intentionally simple; don't speculatively annotate.
- Doc comments only where a public symbol is non-obvious — one line, terse. Most blocks need none.
- `.editorconfig` enforces 4-space indent, 120-char lines, CRLF line endings, no trailing whitespace, no final newline.
