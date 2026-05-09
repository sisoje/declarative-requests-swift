/// The HTTP method for the request.
///
/// Use one of the standard cases for typical methods, or ``custom(_:)`` for
/// methods not covered by the enum (e.g. WebDAV verbs).
///
/// ```swift
/// let getRequest = try URLRequest {
///     Method.GET
///     BaseURL("https://api.example.com")
/// }
///
/// let propfind = try URLRequest {
///     Method.custom("PROPFIND")
///     BaseURL("https://files.example.com")
/// }
/// ```
public enum Method: String, RequestBuildable {
    /// `GET`
    case GET
    /// `HEAD`
    case HEAD
    /// `POST`
    case POST
    /// `PUT`
    case PUT
    /// `DELETE`
    case DELETE
    /// `CONNECT`
    case CONNECT
    /// `OPTIONS`
    case OPTIONS
    /// `TRACE`
    case TRACE
    /// `PATCH`
    case PATCH

    public var body: some RequestBuildable {
        RequestState[\.request.httpMethod, rawValue]
    }

    /// Use a non-standard HTTP method.
    ///
    /// The string is written verbatim to `URLRequest.httpMethod`, so make sure
    /// it is in the case the server expects.
    ///
    /// - Parameter method: The HTTP method to use.
    /// - Returns: A ``RequestBuildable`` that sets the request's method.
    public static func custom(_ method: String) -> some RequestBuildable {
        RequestState[\.request.httpMethod, method]
    }
}
