//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPageScreen : IQScreen {
    
    associatedtype PageBar : IQPageBarView
    
    var pageBarView: PageBar { get }
    var pageBarSize: QFloat { get }
    
}

public extension IQPageScreen {
    
    var pageBarSize: QFloat {
        return 50
    }
    
    func updatePageBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard let container = self.container as? IQPageContainer else {
            completion?()
            return
        }
        container.updateBar(animated: animated, completion: completion)
    }
    
}
