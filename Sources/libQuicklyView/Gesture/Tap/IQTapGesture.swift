//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQTapGesture : IQGesture {
    
    var numberOfTapsRequired: UInt { set get }
    var numberOfTouchesRequired: UInt { set get }
    
    @discardableResult
    func numberOfTapsRequired(_ value: UInt) -> Self
    
    @discardableResult
    func numberOfTouchesRequired(_ value: UInt) -> Self
    
    @discardableResult
    func onTriggered(_ value: (() -> Void)?) -> Self
    
}
