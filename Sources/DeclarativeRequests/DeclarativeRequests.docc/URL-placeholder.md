# ``Foundation/URL/placeholder``

An empty placeholder URL used as the seed value for ``RequestState`` before
any ``BaseURL`` or ``Endpoint`` block has run.

## Overview

The DSL is designed so the URL is assembled from blocks; this placeholder
exists only because `URLRequest` requires a non-optional URL at
initialization. ``BaseURL`` is expected to replace it before the request
is consumed.
