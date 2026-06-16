import SwiftUI

public struct HeaderCap {
    @Binding public var value: String?
    public var addValue: (_ value: String) -> Void
}
