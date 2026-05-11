# ``AllowAccess``

Toggles which kinds of network connections the request is allowed to use.

## Overview

Each case maps to one of the `allowsXAccess` flags on `URLRequest`. Use
these to opt out of expensive or constrained networks, or to require
cellular for certain workloads.

```swift
let request = try URLRequest {
    BaseURL("https://api.example.com")
    Endpoint("/sync")
    AllowAccess.cellular(true)
    AllowAccess.expensiveNetwork(false)   // skip if user is on metered Wi-Fi
    AllowAccess.constrainedNetwork(false) // skip in Low Data Mode
}
```

### cellular(_:)

Toggle `URLRequest.allowsCellularAccess`.

- Parameter value: `true` to permit cellular, `false` to deny.

### expensiveNetwork(_:)

Toggle `URLRequest.allowsExpensiveNetworkAccess`.

- Parameter value: `true` to permit expensive networks (e.g. cellular,
  personal hotspot), `false` to deny.

### constrainedNetwork(_:)

Toggle `URLRequest.allowsConstrainedNetworkAccess`.

- Parameter value: `true` to permit constrained networks (Low Data
  Mode), `false` to deny.

### ultraConstrainedNetwork(_:)

Toggle `URLRequest.allowsUltraConstrainedNetworkAccess`. Only applied
on platforms where the property exists; on older OS versions the block
is a no-op.

- Parameter value: `true` to permit ultra-constrained networks,
  `false` to deny.

## Topics

### Cases
- ``cellular(_:)``
- ``expensiveNetwork(_:)``
- ``constrainedNetwork(_:)``
- ``ultraConstrainedNetwork(_:)``

### Composing

- ``body``
- ``request``
