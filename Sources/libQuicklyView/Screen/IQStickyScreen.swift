//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStickyScreen : IQScreen {
    
    associatedtype StickyBar : IQBarView
    
    var stickyView: StickyBar { get }
    var stickySize: Float { get }
    var stickyHidden: Bool { get }
    
}

public extension IQStickyScreen {
    
    var stickySize: Float {
        return 96
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
