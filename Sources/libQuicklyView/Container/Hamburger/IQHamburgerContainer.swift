//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQHamburgerContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var leadingContainer: IQHamburgerContentContainer? { set get }
    var contentContainers: IQHamburgerContentContainer { set get }
    var trailingContainer: IQHamburgerContentContainer? { set get }
    
}

public protocol IQHamburgerContentContainer : IQContainer {
    
    var hamburgerContainer: IQHamburgerContainer? { set get }
    
}

public extension IQHamburgerContentContainer where Self : IQContainerParentable {
    
    var hamburgerContainer: IQHamburgerContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQHamburgerContainer }
    }
    
}
