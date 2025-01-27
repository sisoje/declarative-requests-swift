import Foundation
import SwiftUI

struct RequestBuilderState {
    var pathComponents: URLComponents = .init()
    var request: URLRequest = .init()
}
