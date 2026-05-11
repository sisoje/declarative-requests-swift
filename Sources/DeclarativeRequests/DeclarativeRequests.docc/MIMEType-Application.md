# ``MIMEType/Application``

MIME types in the `application` top-level type.

## Overview

Groups machine-readable formats — JSON, XML, form encodings, office
documents, and archives:

```swift
MIMEType.Application.json           // "application/json"
MIMEType.Application.formURLEncoded // "application/x-www-form-urlencoded"
MIMEType.Application.pdf            // "application/pdf"
```

## Topics

### Data Interchange

- ``json``
- ``xml``
- ``yaml``
- ``graphql``
- ``formURLEncoded``

### JSON Variants

- ``jsonPatch``
- ``mergePatch``
- ``problemJSON``
- ``ldJSON``
- ``vendorAPIJSON``
- ``halJSON``

### XML Variants

- ``atomXML``
- ``rssXML``
- ``soapXML``

### Binary

- ``octetStream``
- ``pdf``
- ``javascript``
- ``wasm``

### Office Documents

- ``msword``
- ``docx``
- ``xls``
- ``xlsx``
- ``ppt``
- ``pptx``
- ``rtf``

### Archives

- ``zip``
- ``gzip``
- ``tar``
- ``sevenZip``
- ``rar``
