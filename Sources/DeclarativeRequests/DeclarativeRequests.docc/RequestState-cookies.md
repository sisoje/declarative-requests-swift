# ``RequestState/cookies``

The cookies currently encoded into the `Cookie` header, parsed lazily.

## Overview

Reads parse the existing header. Writes serialize the dictionary back as a
`name=value; ...` string. Setting an empty dictionary clears the header.
