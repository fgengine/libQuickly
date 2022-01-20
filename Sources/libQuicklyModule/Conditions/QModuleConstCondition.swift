//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public class QModuleConstCondition : IQModuleCondition {
    
    public var state: Bool
    
    public init(_ state: Bool) {
        self.state = state
    }
    
}
