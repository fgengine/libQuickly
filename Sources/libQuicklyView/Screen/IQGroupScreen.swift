//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGroupScreen : IQScreen {
    
    associatedtype GroupBar : IQGroupBarView
    
    var groupBarView: GroupBar { get }
    var groupBarSize: Float { get }
    var groupBarVisibility: Float { get }
    var groupBarHidden: Bool { get }
    
}

public extension IQGroupScreen {
    
    @inlinable
    var groupContainer: IQGroupContainer? {
        return self.container as? IQGroupContainer
    }
    
    var groupBarSize: Float {
        return 55
    }
    
    var groupBarVisibility: Float {
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
