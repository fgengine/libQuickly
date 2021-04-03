//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGroupScreen : IQScreen {
    
    associatedtype GroupBar : IQGroupBarView
    
    var groupBarView: GroupBar { get }
    var groupBarSize: QFloat { get }
    var groupBarVisibility: QFloat { get }
    var groupBarHidden: Bool { get }
    
}

public extension IQGroupScreen {
    
    @inlinable
    var groupContainer: IQGroupContainer? {
        return self.container as? IQGroupContainer
    }
    
    var groupBarSize: QFloat {
        return 55
    }
    
    var groupBarVisibility: QFloat {
        return 1
    }
    
    var groupBarHidden: Bool {
        return false
    }
    
    func updateGroupBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard let groupContainer = self.groupContainer else {
            completion?()
            return
        }
        groupContainer.updateBar(animated: animated, completion: completion)
    }
    
}
