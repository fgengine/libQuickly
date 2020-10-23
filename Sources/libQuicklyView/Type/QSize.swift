//
//  libQuicklyView
//

import Foundation

public struct QSize : Hashable {
    
    public var width: QFloat
    public var height: QFloat
    
    @inlinable
    public init() {
        self.width = 0
        self.height = 0
    }
    
    @inlinable
    public init(
        width: QFloat,
        height: QFloat
    ) {
        self.width = width
        self.height = height
    }
    
}

public extension QSize {
    
    var isInfinite: Bool {
        return self.width.isInfinite == true && self.height.isInfinite == true
    }
    var aspectRatio: QFloat {
        return self.width / self.height
    }
    
}

public extension QSize {
    
    @inlinable
    func wrap() -> QSize {
        return QSize(
            width: self.height,
            height: self.width
        )
    }
    
    @inlinable
    func ceil() -> QSize {
        return QSize(
            width: self.width.ceil(),
            height: self.height.ceil()
        )
    }
    
    @inlinable
    func lerp(_ to: QSize, progress: QFloat) -> QSize {
        return QSize(
            width: self.width.lerp(to.width, progress: progress),
            height: self.height.lerp(to.height, progress: progress)
        )
    }
    
    @inlinable
    func apply(inset: QInset) -> QSize {
        let width = self.width.isInfinite == false ? self.width - (inset.left + inset.right) : self.width
        let height = self.height.isInfinite == false ? self.height - (inset.top + inset.bottom) : self.height
        return QSize(width: width, height: height)
    }
    
    @inlinable
    func apply(width: QDimensionBehaviour, height: QDimensionBehaviour) -> QSize {
        return QSize(
            width: self.width.apply(width),
            height: self.height.apply(height)
        )
    }
    
    @inlinable
    func aspectFit(size: QSize) -> QSize {
        let iw = floor(self.width)
        let ih = floor(self.height)
        let bw = floor(size.width)
        let bh = floor(size.height)
        let fw = bw / iw
        let fh = bh / ih
        let sc = (fw < fh) ? fw : fh
        let rw = iw * sc
        let rh = ih * sc
        return QSize(
            width: rw,
            height: rh
        )
    }
    
    @inlinable
    func aspectFill(size: QSize) -> QSize {
        let iw = floor(self.width)
        let ih = floor(self.height)
        let bw = floor(size.width)
        let bh = floor(size.height)
        let fw = bw / iw
        let fh = bh / ih
        let sc = (fw > fh) ? fw : fh
        let rw = iw * sc
        let rh = ih * sc
        return QSize(
            width: rw,
            height: rh
        )
    }

    
}

public extension QSize {
    
    @inlinable
    static prefix func - (size: QSize) -> QSize {
        return QSize(
            width: -size.width,
            height: -size.height
        )
    }
    
    @inlinable
    static func + (lhs: QSize, rhs: QSize) -> QSize {
        return QSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
    
    @inlinable
    static func - (lhs: QSize, rhs: QSize) -> QSize {
        return QSize(
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
        )
    }
    
    @inlinable
    static func * (lhs: QSize, rhs: QSize) -> QSize {
        return QSize(
            width: lhs.width * rhs.width,
            height: lhs.height * rhs.height
        )
    }
    
    @inlinable
    static func * (lhs: QSize, rhs: QFloat) -> QSize {
        return QSize(
            width: lhs.width * rhs,
            height: lhs.height * rhs
        )
    }
    
    @inlinable
    static func / (lhs: QSize, rhs: QSize) -> QSize {
        return QSize(
            width: lhs.width / rhs.width,
            height: lhs.height / rhs.height
        )
    }
    
    @inlinable
    static func / (lhs: QSize, rhs: QFloat) -> QSize {
        return QSize(
            width: lhs.width / rhs,
            height: lhs.height / rhs
        )
    }
    
}
