//
//  libQuicklyView
//

import CoreGraphics

public struct QPoint : Hashable {
    
    public var x: QFloat
    public var y: QFloat
    
    @inlinable
    public init() {
        self.x = 0
        self.y = 0
    }
    
    @inlinable
    public init(
        x: QFloat,
        y: QFloat
    ) {
        self.x = x
        self.y = y
    }
    
}

public extension QPoint {
    
    func wrap() -> QPoint {
        return QPoint(
            x: self.y,
            y: self.x
        )
    }

    func distance(to: QPoint) -> QFloat {
        return sqrt(pow(to.x - self.x, 2) + pow(to.y - self.y, 2))
    }

    func length() -> QFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    func lerp(_ to: QPoint, progress: QFloat) -> QPoint {
        return QPoint(
            x: self.x.lerp(to.x, progress: progress),
            y: self.y.lerp(to.y, progress: progress)
        )
    }
    
}

public extension QPoint {
    
    @inlinable
    static prefix func - (point: QPoint) -> QPoint {
        return QPoint(
            x: -point.x,
            y: -point.y
        )
    }
    
    @inlinable
    static func + (lhs: QPoint, rhs: QPoint) -> QPoint {
        return QPoint(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    
    @inlinable
    static func - (lhs: QPoint, rhs: QPoint) -> QPoint {
        return QPoint(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }
    
    @inlinable
    static func * (lhs: QPoint, rhs: QPoint) -> QPoint {
        return QPoint(
            x: lhs.x * rhs.x,
            y: lhs.y * rhs.y
        )
    }
    
    @inlinable
    static func * (lhs: QPoint, rhs: QFloat) -> QPoint {
        return QPoint(
            x: lhs.x * rhs,
            y: lhs.y * rhs
        )
    }
    
    @inlinable
    static func / (lhs: QPoint, rhs: QPoint) -> QPoint {
        return QPoint(
            x: lhs.x / rhs.x,
            y: lhs.y / rhs.y
        )
    }
    
    @inlinable
    static func / (lhs: QPoint, rhs: QFloat) -> QPoint {
        return QPoint(
            x: lhs.x / rhs,
            y: lhs.y / rhs
        )
    }
    
}
