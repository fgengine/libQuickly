//
//  libQuicklyCore
//

import Foundation

public struct QInset : Hashable {
    
    public var top: QFloat
    public var left: QFloat
    public var right: QFloat
    public var bottom: QFloat
    
    @inlinable
    public init(
        top: QFloat = 0,
        left: QFloat = 0,
        right: QFloat = 0,
        bottom: QFloat = 0
    ) {
        self.top = top
        self.left = left
        self.right = right
        self.bottom = bottom
    }
    
    @inlinable
    public init(
        horizontal: QFloat = 0,
        vertical: QFloat = 0
    ) {
        self.top = horizontal
        self.left = vertical
        self.right = vertical
        self.bottom = horizontal
    }
    
}

public extension QInset {
    
    @inlinable
    static prefix func - (inset: QInset) -> QInset {
        return QInset(
            top: -inset.top,
            left: -inset.left,
            right: -inset.right,
            bottom: -inset.bottom
        )
    }
    
    @inlinable
    static func + (left: QInset, right: QInset) -> QInset {
        return QInset(
            top: left.top + right.top,
            left: left.left + right.left,
            right: left.right + right.right,
            bottom: left.bottom + right.bottom
        )
    }
    
    @inlinable
    static func += (left: inout QInset, right: QInset) {
        left = left + right
    }
    
    @inlinable
    static func - (left: QInset, right: QInset) -> QInset {
        return QInset(
            top: left.top - right.top,
            left: left.left - right.left,
            right: left.right - right.right,
            bottom: left.bottom - right.bottom
        )
    }
    
    @inlinable
    static func -= (left: inout QInset, right: QInset) {
        left = left - right
    }

}
