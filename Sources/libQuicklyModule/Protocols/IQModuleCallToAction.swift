//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public protocol IQModuleCallToAction {
    
    var condition: IQModuleCondition { get }
    var dependencies: [IQModuleCallToAction] { get }
    
    func show()
    
}

public extension IQModuleCallToAction {
    
    @inlinable
    var canShow: Bool {
        return self.condition.state
    }
    
}
