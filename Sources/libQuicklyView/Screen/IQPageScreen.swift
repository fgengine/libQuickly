//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPageScreen : IQScreen {
    
    associatedtype PageBar : IQPageBarView
    
    var pageBarView: PageBar { get }
    var pageBarSize: QFloat { get }
    var pageBarVisibility: QFloat { get }
    var pageBarHidden: Bool { get }
    
}

public extension IQPageScreen {
    
    @inlinable
    var pageContainer: IQPageContainer? {
        return self.container as? IQPageContainer
    }
    
    var pageBarSize: QFloat {
        return 50
    }
    
    var pageBarVisibility: QFloat {
        return 1
    }
    
    var pageBarHidden: Bool {
        return false
    }
    
    func updatePageBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard let pageContainer = self.pageContainer else {
            completion?()
            return
        }
        pageContainer.updateBar(animated: animated, completion: completion)
    }
    
}
