//
//  libQuicklyView
//

import Foundation

public struct QColor : Hashable {
    
    public var r: Float
    public var g: Float
    public var b: Float
    public var a: Float
    
    @inlinable
    public init() {
        self.r = 0
        self.g = 0
        self.b = 0
        self.a = 0
    }
    
    @inlinable
    public init(
        r: Float,
        g: Float,
        b: Float,
        a: Float = 1
    ) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    @inlinable
    public init(
        r: UInt8,
        g: UInt8,
        b: UInt8,
        a: UInt8 = 255
    ) {
        self.r = Float(r) / 255
        self.g = Float(g) / 255
        self.b = Float(b) / 255
        self.a = Float(a) / 255
    }
    
    @inlinable
    public init(
        rgba: UInt32
    ) {
        self.r = Float((rgba >> 24) & 0xff) / 255.0
        self.g = Float((rgba >> 16) & 0xff) / 255.0
        self.b = Float((rgba >> 8) & 0xff) / 255.0
        self.a = Float(rgba & 0xff) / 255.0
    }
    
    @inlinable
    public init(
        rgb: UInt32
    ) {
        self.r = Float((rgb >> 16) & 0xff) / 255.0
        self.g = Float((rgb >> 8) & 0xff) / 255.0
        self.b = Float(rgb & 0xff) / 255.0
        self.a = 1
    }
    
}

public extension QColor {
    
    static func random() -> Self {
        return QColor(r: UInt8.random(in: 0 ..< 255), g: UInt8.random(in: 0 ..< 255), b: UInt8.random(in: 0 ..< 255))
    }
    
    var isOpaque: Bool {
        get {
            if (1 - self.a) > Float.leastNonzeroMagnitude {
                return false
            }
            return true
        }
    }
    
}
