# Declarative Request Builders

[![Build](https://github.com/sisoje/declarative-requests-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/sisoje/declarative-requests-swift/actions/workflows/swift.yml)

A concise and declarative way to build and modify `URLRequest` using SwiftUI-inspired state management and composable builder nodes.
```mermaid
flowchart LR
    RequestInit["init with empty url"] --> request
    ComponentsInit["init default"] --> path
    RequestBuilder -- modifies --> RequestState

    subgraph RequestState
        request
        path
    end
 
    request -- after modifications --> FinalRequest["final request"]

    subgraph RequestBuilder
        function1 --> dots["..."]
        dots --> functionN
    end
```

## Key Concepts

- **State Management**: `RequestBuilderState` maintains the state for the `URLRequest` and `URLComponents`.
- **Builder Nodes**: Protocol-based components like `HTTPMethod`, `JSONBody`, and `QueryParams` modify `RequestBuilderState`.
- **Result Builders**: Use `RequestBuilder` to declaratively compose multiple `RequestBuilderNode` operations.

## Example Usage

```swift
let request = try URLRequest {
    HTTPMethod.POST
    JSONBody(value: 1)
    Endpoint(path: "getLanguage")
    QueryParams(params: ["languageId": "1"])
    BaseURL(url: URL(string: "https://google.com")!)
}
```

This builds a `POST` request to `https://google.com/getLanguage?languageId=1` declaratively.

## Features
- **Composable Nodes**: Easily add custom `RequestBuilderNode` types.
- **Stateless Logic**: Decouples state from mutation logic.
- **Testable**: Validate requests through isolated `RequestBuilderState`.

Perfect for creating and managing HTTP requests in a clean, declarative style.
