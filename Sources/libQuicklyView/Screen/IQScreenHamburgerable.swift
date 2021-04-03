//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenHamburgerable : AnyObject {
    
    var hamburgerSize: QFloat { get }
    var hamburgerLimit: QFloat { get }
    
}

public extension IQScreenHamburgerable {
    
    var hamburgerSize: QFloat {
        return 240
    }
    
    var hamburgerLimit: QFloat {
        return 120
    }
    
}

public extension IQScreenHamburgerable where Self : IQScreen {
    
    @inlinable
    var hamburgerContentContainer: IQHamburgerContentContainer? {
        guard let contentContainer = self.container as? IQHamburgerContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var hamburgerContainer: IQHamburgerContainer? {
        return self.hamburgerContentContainer?.hamburgerContainer
    }
    
}
