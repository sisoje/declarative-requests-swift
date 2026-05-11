# Builder Blocks

Composable pieces that describe each part of an HTTP request.

## Overview

Every block conforms to ``RequestBuildable`` and maps to one piece of the
raw HTTP request. Declare them top to bottom inside a ``RequestBuilder``
closure and each block's transform is applied in order.

Blocks follow two conventions:

- **Last write wins** for singular properties (method, URL, body). To
  accumulate values (cookies, query items, additive headers), the block
  reads-then-writes the existing value.
- **Compose with `body`.** Custom blocks return other blocks from their
  `body` property, the same way SwiftUI views compose.

## Topics

### URL and Path

- ``BaseURL``
- ``Endpoint``
- ``Query``

### Method, Headers, and Auth

- ``Method``
- ``Header``
- ``Cookie``
- ``Authorization``
- ``ContentType``
- ``Accept``

### Request Body

- ``RequestBody``
- ``MultipartPart``
- ``RequestBody/MultipartStrategy``
- ``MultipartBuilder``

### Networking Configuration

- ``Timeout``
- ``CachePolicy``
- ``NetworkServiceType``
- ``HTTPShouldHandleCookies``
- ``AllowAccess``
