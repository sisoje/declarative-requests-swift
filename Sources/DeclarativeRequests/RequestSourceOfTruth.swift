import Foundation
import SwiftUI

final class RequestSourceOfTruth: Sendable {
    init(pathComponents: URLComponents = .init(), request: URLRequest = .init()) {
        self.request = request
        self.pathComponents = pathComponents
    }

    nonisolated(unsafe) var pathComponents: URLComponents
    nonisolated(unsafe) var request: URLRequest
}

extension RequestSourceOfTruth {
    var state: RequestState {
        RequestState(
            request: Binding { self.request } set: { self.request = $0 },
            pathComponents: Binding { self.pathComponents } set: { self.pathComponents = $0 }
        )
    }
}
