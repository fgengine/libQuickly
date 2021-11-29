//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStickyScreen : IQScreen {
    
    associatedtype StickyBar : IQBarView
    
    var stickyView: StickyBar { get }
    var stickyVisibility: Float { get }
    var stickyHidden: Bool { get }
    
}

public extension IQStickyScreen {
    
    var stickyVisibility: Float {
        return 1
    }
    
    var stickyHidden: Bool {
        return false
    }
    
    @inlinable
    var stickyContainer: IQStickyContainer? {
        return self.container as? IQStickyContainer
    }
    
    func updateSticky(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.stickyContainer?.updateOverlay(animated: animated, completion: completion)
    }
    
}
