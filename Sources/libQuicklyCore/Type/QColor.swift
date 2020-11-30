//
//  libQuicklyCore
//

import Foundation

public struct QColor : Hashable {
    
    public var r: QFloat
    public var g: QFloat
    public var b: QFloat
    public var a: QFloat
    
    @inlinable
    public init() {
        self.r = 0
        self.g = 0
        self.b = 0
        self.a = 0
    }
    
    @inlinable
    public init(
        r: QFloat,
        g: QFloat,
        b: QFloat,
        a: QFloat = 1
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
        self.r = QFloat(r) / 255
        self.g = QFloat(g) / 255
        self.b = QFloat(b) / 255
        self.a = QFloat(a) / 255
    }
    
    @inlinable
    public init(
        rgba: UInt32
    ) {
        self.r = QFloat((rgba >> 24) & 0xff) / 255.0
        self.g = QFloat((rgba >> 16) & 0xff) / 255.0
        self.b = QFloat((rgba >> 8) & 0xff) / 255.0
        self.a = QFloat(rgba & 0xff) / 255.0
    }
    
    @inlinable
    public init(
        rgb: UInt32
    ) {
        self.r = QFloat((rgb >> 16) & 0xff) / 255.0
        self.g = QFloat((rgb >> 8) & 0xff) / 255.0
        self.b = QFloat(rgb & 0xff) / 255.0
        self.a = 1
    }
    
}

public extension QColor {
    
    var isOpaque: Bool {
        get {
            if (1 - self.a) > QFloat.leastNonzeroMagnitude {
                return false
            }
            return true
        }
    }
    
}
