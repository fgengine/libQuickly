//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public class QModuleLogicNotCondition : IQModuleCondition {
    
    public var state: Bool {
        return !self._condition.state
    }
    
    private var _condition: IQModuleCondition
    
    public init(_ condition: IQModuleCondition) {
        self._condition = condition
    }
    
}
