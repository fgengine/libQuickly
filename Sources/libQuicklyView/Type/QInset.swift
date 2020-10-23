//
//  libQuicklyView
//

import Foundation

public struct QInset : Hashable {
    
    public var top: QFloat
    public var left: QFloat
    public var right: QFloat
    public var bottom: QFloat
    
    @inlinable
    public init() {
        self.top = 0
        self.left = 0
        self.right = 0
        self.bottom = 0
    }
    
    @inlinable
    public init(
        top: QFloat,
        left: QFloat,
        right: QFloat,
        bottom: QFloat
    ) {
        self.top = top
        self.left = left
        self.right = right
        self.bottom = bottom
    }
    
    @inlinable
    public init(
        horizontal: QFloat,
        vertical: QFloat
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

}
