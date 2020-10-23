//
//  libQuicklyView
//

#if os(OSX)

import AppKit

public extension QTextAlignment {
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified: return .justified
        case .natural: return .natural
        }
    }
    
    init(_ nsTextAlignment: NSTextAlignment) {
        switch nsTextAlignment {
        case .left: self = .left
        case .center: self = .center
        case .right: self = .right
        case .justified: self = .justified
        case .natural: self = .natural
        @unknown default:
            fatalError()
        }
    }
    
}

#endif
