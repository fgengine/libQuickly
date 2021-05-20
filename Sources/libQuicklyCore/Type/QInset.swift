//
//  libQuicklyCore
//

import Foundation

public struct QInset : Hashable {
    
    public var top: Float
    public var left: Float
    public var right: Float
    public var bottom: Float
    
    @inlinable
    public init(
        top: Float = 0,
        left: Float = 0,
        right: Float = 0,
        bottom: Float = 0
    ) {
        self.top = top
        self.left = left
        self.right = right
        self.bottom = bottom
    }
    
    @inlinable
    public init(
        horizontal: Float = 0,
        vertical: Float = 0
    ) {
        self.top = vertical
        self.left = horizontal
        self.right = horizontal
        self.bottom = vertical
    }
    
}

public extension QInset {
    
    @inlinable
    var horizontal: Float {
        return self.left + self.right
    }
    
    @inlinable
    var vertical: Float {
        return self.top + self.bottom
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
