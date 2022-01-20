//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public protocol IQModuleFeature {
    
    var condition: IQModuleCondition { get }
    
}

public extension IQModuleFeature {
    
    @inlinable
    var isEnabled: Bool {
        return self.condition.state
    }
    
}
