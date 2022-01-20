//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public class QModuleLogicAndCondition : IQModuleCondition {
    
    public var state: Bool {
        guard self._conditions.isEmpty == false else {
            return false
        }
        for condition in self._conditions {
            if condition.state == false {
                return false
            }
        }
        return true
    }
    
    private var _conditions: [IQModuleCondition]
    
    public init(_ conditions: [IQModuleCondition]) {
        self._conditions = conditions
    }
    
}
