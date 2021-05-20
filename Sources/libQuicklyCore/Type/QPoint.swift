//
//  libQuicklyCore
//

import CoreGraphics

public struct QPoint : Hashable {
    
    public var x: Float
    public var y: Float
    
    @inlinable
    public init(
        x: Float = 0,
        y: Float = 0
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

    func distance(to: QPoint) -> Float {
        return sqrt(pow(to.x - self.x, 2) + pow(to.y - self.y, 2))
    }

    func length() -> Float {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    func lerp(_ to: QPoint, progress: Float) -> QPoint {
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
    static func * (lhs: QPoint, rhs: Float) -> QPoint {
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
    static func / (lhs: QPoint, rhs: Float) -> QPoint {
        return QPoint(
            x: lhs.x / rhs,
            y: lhs.y / rhs
        )
    }
    
}
