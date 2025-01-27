![Build](https://github.com/sisoje/declarative-requests-swift/.github/workflows/swift.yml/badge.svg)

# Declarative Request Builders

A concise and declarative way to build and modify `URLRequest` using SwiftUI-inspired state management and composable builder nodes.

## Key Concepts

- **State Management**: `RequestSourceOfTruth` maintains the source of truth for `URLRequest`, `URLComponents`, and the base URL.
- **Builder Nodes**: Protocol-based components like `HttpMethod`, `JSONBody`, and `QueryParams` modify `RequestState`.
- **Result Builders**: Use `RequestBuilder` to declaratively compose multiple `BuilderNode` operations.

## Example Usage

```swift
@Test func testUrl() throws {
    let request = try URL(string: "https://google.com/")?.request {
        HttpMethod(method: .GET)
        Endpoint(path: "getLanguage")
        QueryParams(params: ["languageId": "1"])
    }
    #expect(request?.url?.absoluteString == "https://google.com/getLanguage?languageId=1")
}
```

This builds a `GET` request to `https://google.com/getLanguage?languageId=1` declaratively.

## Features
- **Composable Nodes**: Easily add custom `BuilderNode` types.
- **Stateless Logic**: Decouples state from mutation logic.
- **Testable**: Validate requests through isolated `RequestState`.

Perfect for creating and managing HTTP requests in a clean, declarative style.
