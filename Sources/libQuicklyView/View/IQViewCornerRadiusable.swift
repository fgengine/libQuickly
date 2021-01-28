//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QViewCornerRadius {
    case none
    case manual(radius: QFloat)
    case auto
}

public protocol IQViewCornerRadiusable : AnyObject {
    
    var cornerRadius: QViewCornerRadius { get }
    
    @discardableResult
    func cornerRadius(_ value: QViewCornerRadius) -> Self
    
}
