//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public struct QFont : Equatable {

    public var native: UIFont
    
    @inlinable
    public init(
        weight: QFontWeight,
        size: Float
    ) {
        self.native = UIFont.systemFont(ofSize: CGFloat(size), weight: weight.uiFontWeight)
        
    }
    
    @inlinable
    public init(
        name: String,
        size: Float
    ) {
        self.native = UIFont(name: name, size: CGFloat(size))!
    }
    
    @inlinable
    public init(
        _ native: UIFont
    ) {
        self.native = native
    }
    
}

public extension QFont {
    
    @inlinable
    var lineHeight: Float {
        return Float(self.native.lineHeight)
    }
    
    @inlinable
    func withSize(_ size: Float) -> QFont {
        return QFont(self.native.withSize(CGFloat(size)))
    }
    
}

public extension QFontWeight {
    
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
    
    init(_ uiFontWeight: UIFont.Weight) {
        switch uiFontWeight {
        case .ultraLight: self = .ultraLight
        case .thin: self = .thin
        case .light: self = .light
        case .regular: self = .regular
        case .medium: self = .medium
        case .semibold: self = .semibold
        case .bold: self = .bold
        case .heavy: self = .heavy
        case .black: self = .black
        default: fatalError()
        }
    }
    
}

#endif
