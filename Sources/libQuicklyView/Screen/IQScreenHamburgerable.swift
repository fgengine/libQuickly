//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenHamburgerable : AnyObject {
    
    var hamburgerSize: Float { get }
    var hamburgerLimit: Float { get }
    
}

public extension IQScreenHamburgerable {
    
    var hamburgerSize: Float {
        return 240
    }
    
    var hamburgerLimit: Float {
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
