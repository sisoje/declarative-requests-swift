# ``MultipartPart/file(name:fileURL:type:filename:)``

A file part loaded from disk. With the streamed strategy, the file is read in chunks.

- Parameters:
  - name: The part name.
  - fileURL: The local file URL.
  - type: The MIME type. Defaults to ``MIMEType/octetStream``.
  - filename: Override for the filename in the `Content-Disposition` header. Defaults to the file's last path component.
