import Foundation

public enum CachePolicy: RequestBuildable {
    case useProtocolCachePolicy
    case reloadIgnoringLocalCacheData
    case reloadIgnoringLocalAndRemoteCacheData
    case returnCacheDataElseLoad
    case returnCacheDataDontLoad
    case reloadRevalidatingCacheData

    var policy: URLRequest.CachePolicy {
        switch self {
        case .useProtocolCachePolicy: .useProtocolCachePolicy
        case .reloadIgnoringLocalCacheData: .reloadIgnoringLocalCacheData
        case .reloadIgnoringLocalAndRemoteCacheData: .reloadIgnoringLocalAndRemoteCacheData
        case .returnCacheDataElseLoad: .returnCacheDataElseLoad
        case .returnCacheDataDontLoad: .returnCacheDataDontLoad
        case .reloadRevalidatingCacheData: .reloadRevalidatingCacheData
        }
    }

    public var body: some RequestBuildable {
        RequestMutation[\.cachePolicy, policy]
    }
}
