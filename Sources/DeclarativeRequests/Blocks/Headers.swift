import Foundation

struct Headers: RequestBuilderModifyNode {
    internal init(_ headers: [String : String]) {
        self.headers = headers
    }
    
    internal init<S: Sequence>(_ headers: S) where S.Element == (String, String) {
        self.headers = Dictionary(headers) { _, new in new }
    }
    
    static func contentType(_ value: String) -> Headers {
        Headers(["Content-Type": value])
    }
    
    static func accept(_ value: String) -> Headers {
        Headers(["Accept": value])
    }
    
    static func authorization(_ value: String) -> Headers {
        Headers(["Authorization": value])
    }
    
    static func userAgent(_ value: String) -> Headers {
        Headers(["User-Agent": value])
    }
    
    static func origin(_ value: String) -> Headers {
        Headers(["origin": value])
    }
    
    static func referer(_ value: String) -> Headers {
        Headers(["Referer": value])
    }
    
    static func acceptLanguage(_ value: String) -> Headers {
        Headers(["Accept-Language": value])
    }
    
    static func acceptEncoding(_ value: String) -> Headers {
        Headers(["Accept-Encoding": value])
    }
    
    let headers: [String: String]
    
    func modify(state: inout RequestBuilderState) {
        state.request.allHTTPHeaderFields = state.request.allHTTPHeaderFields ?? [:]
        state.request.allHTTPHeaderFields?.merge(headers) { current, new in new }
    }
}
