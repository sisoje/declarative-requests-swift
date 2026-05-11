# ``ContentType``

A typed identifier for an HTTP `Content-Type` value.

## Overview

Used directly as a block to set the `Content-Type` header, and as a
parameter on body blocks like ``RequestBody`` and ``MultipartPart`` to
label payload bytes:

```swift
// As a block:
ContentType.JSON  // sets Content-Type: application/json

// As a value passed to other blocks:
RequestBody.data(svgData, type: .SVG)
MultipartPart.data(name: "avatar", filename: "a.png", data: png, type: .PNG)
```

## Topics

### Application

- ``URLEncoded``
- ``JSON``
- ``Stream``
- ``PDF``
- ``XML``
- ``ZIP``
- ``ZIP7``
- ``GZIP``
- ``DOC``
- ``XLS``
- ``PPT``
- ``DOCX``
- ``XLSX``
- ``PPTX``
- ``M3U8``

### Text

- ``HTML``
- ``PlainText``
- ``CSS``
- ``CSV``
- ``JS``
- ``Calendar``

### Image

- ``JPEG``
- ``PNG``
- ``GIF``
- ``SVG``
- ``WebP``
- ``TIFF``
- ``BMP``
- ``ICO``

### Audio

- ``MP3``
- ``WAV``
- ``OGGAudio``
- ``AAC``
- ``M4A``
- ``MIDI``
- ``M3U``

### Video

- ``MP4``
- ``MPEG``
- ``WebM``
- ``OGGVideo``
- ``AVI``
- ``TS``

### Font

- ``WOFF``
- ``WOFF2``
- ``TTF``
- ``OTF``

### Composing

- ``body``
- ``request``

### Raw Value

- ``rawValue``
- ``init(rawValue:)``
