//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewLockable : IQViewStyleable {
    
    var isLocked: Bool { set get }
    
    @discardableResult
    func lock(_ value: Bool) -> Self
    
}
