# Declarative Request Builders

A concise and declarative way to build and modify `URLRequest` using SwiftUI-inspired state management and composable builder nodes.

## Key Concepts

- **State Management**: `RequestSourceOfTruth` maintains the source of truth for `URLRequest`, `URLComponents`, and the base URL.
- **Builder Nodes**: Protocol-based components like `HttpMethod`, `JsonBody`, and `AddQueryParams` modify `RequestState`.
- **Result Builders**: Use `RequestBuilder` to declaratively compose multiple `BuilderNode` operations.

## Example Usage

```swift
let builder = RequestBuilderGroup {
    HttpMethod(method: .GET)
    AddQueryParams(params: ["tripId": "1"])
    Endpoint(path: "/getTrip")
    CreateURL()
}
```

This builds a `GET` request to `https://google.com/getTrip?tripId=1` declaratively.

## Features
- **Composable Nodes**: Easily add custom `BuilderNode` types.
- **Stateless Logic**: Decouples state from mutation logic.
- **Testable**: Validate requests through isolated `RequestState`.

Perfect for creating and managing HTTP requests in a clean, declarative style.
