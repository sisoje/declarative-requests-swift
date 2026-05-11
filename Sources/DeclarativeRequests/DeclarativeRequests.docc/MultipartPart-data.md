# ``MultipartPart/data(name:filename:data:type:)``

A file part backed by an in-memory `Data` blob.

- Parameters:
  - name: The part name.
  - filename: The filename sent in the `Content-Disposition` header.
  - data: The raw bytes.
  - type: The MIME type. Defaults to ``MIMEType/octetStream``.
