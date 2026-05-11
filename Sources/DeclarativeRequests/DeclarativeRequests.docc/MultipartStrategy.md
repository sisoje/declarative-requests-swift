# ``RequestBody/MultipartStrategy``

How the multipart body bytes are produced.

## Overview

### inMemory

Assemble the entire payload in memory, then set it as `httpBody`.
Simple, but holds the whole body in RAM.

### streamed(bufferSize:)

Stream the payload from disk on demand. Memory use stays bounded to
roughly `bufferSize` regardless of total payload size, so payloads
in the hundreds of gigabytes are practical.

- `bufferSize`: The chunk size used for both the bound
  stream pair and for reading from disk. Defaults to 64 KB.

## Topics

### Strategies

- ``inMemory``
- ``streamed(bufferSize:)``
