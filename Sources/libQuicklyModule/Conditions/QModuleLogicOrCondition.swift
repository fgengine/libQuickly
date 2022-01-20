//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public class QModuleLogicOrCondition : IQModuleCondition {
    
    public var state: Bool {
        for condition in self._conditions {
            if condition.state == true {
                return true
            }
        }
        return false
    }
    
    private var _conditions: [IQModuleCondition]
    
    public init(_ conditions: [IQModuleCondition]) {
        self._conditions = conditions
    }
    
}
