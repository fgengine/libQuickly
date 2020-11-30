//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGesture : AnyObject {
    
    var isEnabled: Bool { set get }
    var native: QNativeGesture { get }
    
    func location(in view: IQView) -> QPoint
    
}
