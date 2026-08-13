import Foundation

public enum NetworkServiceType: RequestBuildable {
    case `default`
    case video
    case background
    case voice
    case responsiveData
    case avStreaming
    case responsiveAV
    case callSignaling

    var serviceType: URLRequest.NetworkServiceType {
        switch self {
        case .default: .default
        case .video: .video
        case .background: .background
        case .voice: .voice
        case .responsiveData: .responsiveData
        case .avStreaming: .avStreaming
        case .responsiveAV: .responsiveAV
        case .callSignaling: .callSignaling
        }
    }

    public var body: some RequestBuildable {
        RequestMutation[\.networkServiceType, serviceType]
    }
}
