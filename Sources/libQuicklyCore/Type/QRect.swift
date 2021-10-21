//
//  libQuicklyCore
//

import Foundation

public struct QRect : Hashable {
    
    public var origin: QPoint
    public var size: QSize
    
    @inlinable
    public init(
        x: Float,
        y: Float,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(x: x, y: y)
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        x: Float,
        y: Float,
        size: QSize
    ) {
        self.origin = QPoint(x: x, y: y)
        self.size = size
    }
    
    @inlinable
    public init(
        topLeft: QPoint,
        bottomRight: QPoint
    ) {
        self.origin = topLeft
        self.size = QSize(
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }
    
    @inlinable
    public init(
        topLeft: QPoint,
        size: QSize
    ) {
        self.origin = topLeft
        self.size = size
    }
    
    @inlinable
    public init(
        topLeft: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = topLeft
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        top: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: top.x - (size.width / 2),
            y: top.y
        )
        self.size = size
    }
    
    @inlinable
    public init(
        top: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: top.x - (width / 2),
            y: top.y
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        topRight: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: topRight.x - size.width,
            y: topRight.y
        )
        self.size = size
    }
    
    @inlinable
    public init(
        topRight: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: topRight.x - width,
            y: topRight.y
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        left: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: left.x,
            y: left.y - (size.height / 2)
        )
        self.size = size
    }
    
    @inlinable
    public init(
        left: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: left.x,
            y: left.y - (height / 2)
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        center: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: center.x - (size.width / 2),
            y: center.y - (size.height / 2)
        )
        self.size = size
    }
    
    @inlinable
    public init(
        center: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: center.x - (width / 2),
            y: center.y - (height / 2)
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        right: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: right.x - size.width,
            y: right.y - (size.height / 2)
        )
        self.size = size
    }
    
    @inlinable
    public init(
        right: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: right.x - width,
            y: right.y - (height / 2)
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        bottomLeft: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: bottomLeft.x,
            y: bottomLeft.y - size.height
        )
        self.size = size
    }
    
    @inlinable
    public init(
        bottomLeft: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: bottomLeft.x,
            y: bottomLeft.y - height
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        bottom: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: bottom.x - (size.width / 2),
            y: bottom.y - size.height
        )
        self.size = size
    }
    
    @inlinable
    public init(
        bottom: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: bottom.x - (width / 2),
            y: bottom.y - height
        )
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        bottomRight: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: bottomRight.x - size.width,
            y: bottomRight.y - size.height
        )
        self.size = size
    }
    
    @inlinable
    public init(
        bottomRight: QPoint,
        width: Float,
        height: Float
    ) {
        self.origin = QPoint(
            x: bottomRight.x - width,
            y: bottomRight.y - height
        )
        self.size = QSize(width: width, height: height)
    }
    
}

public extension QRect {
    
    static var zero = QRect(x: 0, y: 0, width: 0, height: 0)
    
}

public extension QRect {
    
    @inlinable
    var x: Float {
        return self.origin.x
    }
    
    @inlinable
    var y: Float {
        return self.origin.y
    }
    
    @inlinable
    var width: Float {
        return self.size.width
    }

    @inlinable
    var height: Float {
        return self.size.height
    }

    @inlinable
    var topLeft: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y
        )
    }
    
    
    @inlinable
    var top: QPoint {
        return QPoint(
            x: self.origin.x + (self.size.width / 2),
            y: self.origin.y
        )
    }
    
    
    @inlinable
    var topRight: QPoint {
        return QPoint(
            x: self.origin.x + self.size.width,
            y: self.origin.y
        )
    }
    
    
    @inlinable
    var left: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var center: QPoint {
        return QPoint(
            x: self.origin.x + (self.size.width / 2),
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var right: QPoint {
        return QPoint(
            x: self.origin.x + self.size.width,
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var bottomLeft: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y + self.size.height
        )
    }
    
    
    @inlinable
    var bottom: QPoint {
        return QPoint(
            x: self.origin.x + (self.size.width / 2),
            y: self.origin.y + self.size.height
        )
    }
    
    @inlinable
    var bottomRight: QPoint {
        return QPoint(
            x: self.origin.x + self.size.width,
            y: self.origin.y + self.size.height
        )
    }
    
    @inlinable
    var integral: QRect {
        return QRect(
            topLeft: self.origin.integral,
            size: self.size.integral
        )
    }
    
}

public extension QRect {
    
    @inlinable
    func isContains(point: QPoint) -> Bool {
        guard self.origin.x <= point.x && self.origin.x + self.size.width >= point.x else { return false }
        guard self.origin.y <= point.y && self.origin.y + self.size.height >= point.y else { return false }
        return true
    }

    @inlinable
    func isContains(rect: QRect) -> Bool {
        guard self.origin.x <= rect.origin.x && self.origin.x + self.size.width >= rect.origin.x + rect.size.width else { return false }
        guard self.origin.y <= rect.origin.y && self.origin.y + self.size.height >= rect.origin.y + rect.size.height else { return false }
        return true
    }

    @inlinable
    func isIntersects(rect: QRect) -> Bool {
        guard self.origin.x <= rect.origin.x + rect.size.width && self.origin.x + self.size.width >= rect.origin.x else { return false }
        guard self.origin.y <= rect.origin.y + rect.size.height && self.origin.y + self.size.height >= rect.origin.y else { return false }
        return true
    }
    
    @inlinable
    func isHorizontalIntersects(rect: QRect) -> Bool {
        guard self.origin.x <= rect.origin.x + rect.size.width && self.origin.x + self.size.width >= rect.origin.x else { return false }
        return true
    }
    
    @inlinable
    func isVerticalIntersects(rect: QRect) -> Bool {
        guard self.origin.y <= rect.origin.y + rect.size.height && self.origin.y + self.size.height >= rect.origin.y else { return false }
        return true
    }

    @inlinable
    func offset(x: Float, y: Float) -> QRect {
        return QRect(
            topLeft: self.origin - QPoint(x: x, y: y),
            size: self.size
        )
    }

    @inlinable
    func offset(point: QPoint) -> QRect {
        return QRect(
            topLeft: self.origin - point,
            size: self.size
        )
    }

    @inlinable
    func union(_ to: QRect) -> QRect {
        let minX = min(self.origin.x, to.origin.x)
        let minY = min(self.origin.y, to.origin.y)
        let maxX = max(self.origin.x + self.size.width, to.origin.x + to.size.width)
        let maxY = max(self.origin.y + self.size.height, to.origin.y + to.size.height)
        return QRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    @inlinable
    func lerp(_ to: QRect, progress: Float) -> QRect {
        return QRect(
            x: self.origin.x.lerp(to.origin.x, progress: progress),
            y: self.origin.y.lerp(to.origin.y, progress: progress),
            width: self.size.width.lerp(to.size.width, progress: progress),
            height: self.size.height.lerp(to.size.height, progress: progress)
        )
    }
    
    @inlinable
    func apply(inset: QInset) -> QRect {
        let size = self.size.apply(inset: inset)
        return QRect(
            x: self.origin.x + inset.left,
            y: self.origin.y + inset.top,
            width: size.width,
            height: size.height
        )
    }
    
    @inlinable
    func apply(width: QDimensionBehaviour?, height: QDimensionBehaviour?, aspectRatio: Float? = nil) -> QRect {
        return QRect(
            center: self.center,
            size: self.size.apply(width: width, height: height, aspectRatio: aspectRatio)
        )
    }
    
    @inlinable
    func split(left: Float) -> (left: QRect, right: QRect) {
        return (
            left: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: left,
                height: self.size.height
            ),
            right: QRect(
                x: self.origin.x + left,
                y: self.origin.y,
                width: self.size.width - left,
                height: self.size.height
            )
        )
    }
    
    @inlinable
    func split(right: Float) -> (left: QRect, right: QRect) {
        return (
            left: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width - right,
                height: self.size.height
            ),
            right: QRect(
                x: (self.origin.x + self.size.width) - right,
                y: self.origin.y,
                width: right,
                height: self.size.height
            )
        )
    }
    
    @inlinable
    func split(left: Float, right: Float) -> (left: QRect, middle: QRect, right: QRect) {
        return (
            left: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: left,
                height: self.size.height
            ),
            middle: QRect(
                x: self.origin.x + left,
                y: self.origin.y,
                width: self.size.width - (left + right),
                height: self.size.height
            ),
            right: QRect(
                x: (self.origin.x + self.size.width) - right,
                y: self.origin.y,
                width: right,
                height: self.size.height
            )
        )
    }
    
    @inlinable
    func split(top: Float) -> (top: QRect, bottom: QRect) {
        return (
            top: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width,
                height: top
            ),
            bottom: QRect(
                x: self.origin.x,
                y: self.origin.y + top,
                width: self.size.width,
                height: self.size.height - top
            )
        )
    }
    
    @inlinable
    func split(bottom: Float) -> (top: QRect, bottom: QRect) {
        return (
            top: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width,
                height: self.size.height - bottom
            ),
            bottom: QRect(
                x: self.origin.x,
                y: (self.origin.y + self.size.height) - bottom,
                width: self.size.width,
                height: bottom
            )
        )
    }
    
    @inlinable
    func split(top: Float, bottom: Float) -> (top: QRect, middle: QRect, bottom: QRect) {
        return (
            top: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width,
                height: top
            ),
            middle: QRect(
                x: self.origin.x,
                y: self.origin.y + top,
                width: self.size.width,
                height: self.size.height - (top + bottom)
            ),
            bottom: QRect(
                x: self.origin.x,
                y: (self.origin.y + self.size.height) - bottom,
                width: self.size.width,
                height: bottom
            )
        )
    }
    
    @inlinable
    func grid(rows: UInt, columns: UInt, spacing: QPoint) -> [QRect] {
        var result: [QRect] = []
        if rows > 0 && columns > 0 {
            var origin = self.origin
            let itemSize = QSize(
                width: rows > 1 ? self.size.width / Float(rows - 1) : self.size.width,
                height: columns > 1 ? self.size.height / Float(columns - 1) : self.size.height
            )
            for _ in 0 ..< rows {
                origin.x = self.origin.x
                for _ in 0 ..< columns {
                    result.append(QRect(topLeft: origin, size: itemSize))
                    origin.x += spacing.x
                }
                origin.y += spacing.y
            }
        }
        return result
    }
    
    @inlinable
    func aspectFit(size: QSize) -> QRect {
        let iw = floor(size.width)
        let ih = floor(size.height)
        let bw = floor(self.size.width)
        let bh = floor(self.size.height)
        let fw = bw / iw
        let fh = bh / ih
        let sc = (fw < fh) ? fw : fh
        let rw = iw * sc
        let rh = ih * sc
        let rx = (bw - rw) / 2
        let ry = (bh - rh) / 2
        return QRect(
            x: self.origin.x + rx,
            y: self.origin.y + ry,
            width: rw,
            height: rh
        )
    }
    
    @inlinable
    func aspectFill(size: QSize) -> QRect {
        let iw = floor(size.width)
        let ih = floor(size.height)
        let bw = floor(self.size.width)
        let bh = floor(self.size.height)
        let fw = bw / iw
        let fh = bh / ih
        let sc = (fw > fh) ? fw : fh
        let rw = iw * sc
        let rh = ih * sc
        let rx = (bw - rw) / 2
        let ry = (bh - rh) / 2
        return QRect(
            x: self.origin.x + rx,
            y: self.origin.y + ry,
            width: rw,
            height: rh
        )
    }
    
}
