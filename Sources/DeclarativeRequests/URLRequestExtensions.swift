import Foundation

extension URLRequest {
    init() {
        self = URLRequest(url: URL(fileURLWithPath: ""))
        url = nil
    }
}
