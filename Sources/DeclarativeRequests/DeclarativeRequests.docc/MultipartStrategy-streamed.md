# ``RequestBody/MultipartStrategy/streamed(bufferSize:)``

Stream the payload from disk on demand. Memory use stays bounded to roughly `bufferSize` regardless of total payload size.

- Parameter bufferSize: The chunk size for the bound stream pair and for reading from disk. Defaults to 64 KB.
