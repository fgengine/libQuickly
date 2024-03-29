//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public class QModuleBlockCondition : IQModuleCondition {
    
    public var state: Bool {
        return self._block()
    }
    
    private let _block: () -> Bool
    
    public init(_ block: @escaping () -> Bool) {
        self._block = block
    }
    
}
