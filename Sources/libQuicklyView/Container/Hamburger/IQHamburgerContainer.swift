//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQHamburgerContainer : IQContainer, IQContainerParentable {
    
    var contentContainer: IQHamburgerContentContainer { set get }
    var isShowedLeadingContainer: Bool { get }
    var leadingContainer: IQHamburgerMenuContainer? { set get }
    var isShowedTrailingContainer: Bool { get }
    var trailingContainer: IQHamburgerMenuContainer? { set get }
    var animationVelocity: QFloat { set get }
    
    func showLeadingContainer(animated: Bool, completion: (() -> Void)?)
    func hideLeadingContainer(animated: Bool, completion: (() -> Void)?)
    
    func showTrailingContainer(animated: Bool, completion: (() -> Void)?)
    func hideTrailingContainer(animated: Bool, completion: (() -> Void)?)

}

public extension IQHamburgerContainer {
    
    @inlinable
    func showLeadingContainer(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.showLeadingContainer(animated: animated, completion: completion)
    }
    
    @inlinable
    func hideLeadingContainer(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.hideLeadingContainer(animated: animated, completion: completion)
    }
    
    @inlinable
    func showTrailingContainer(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.showTrailingContainer(animated: animated, completion: completion)
    }
    
    @inlinable
    func hideTrailingContainer(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.hideTrailingContainer(animated: animated, completion: completion)
    }
    
    func set(leadingContainer: IQHamburgerMenuContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated == true {
            if self.isShowedLeadingContainer == true {
                self.hideLeadingContainer(animated: animated, completion: { [weak self] in
                    guard let self = self else { return }
                    self.leadingContainer = leadingContainer
                    self.showLeadingContainer(animated: animated, completion: completion)
                })
            } else {
                self.leadingContainer = leadingContainer
            }
        } else {
            self.leadingContainer = leadingContainer
        }
    }
    
    func set(trailingContainer: IQHamburgerMenuContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated == true {
            if self.isShowedTrailingContainer == true {
                self.hideTrailingContainer(animated: animated, completion: { [weak self] in
                    guard let self = self else { return }
                    self.trailingContainer = trailingContainer
                    self.showTrailingContainer(animated: animated, completion: completion)
                })
            } else {
                self.trailingContainer = trailingContainer
            }
        } else {
            self.trailingContainer = trailingContainer
        }
    }
    
}

public protocol IQHamburgerContentContainer : IQContainer, IQContainerParentable {
    
    var hamburgerContainer: IQHamburgerContainer? { get }

}

public extension IQHamburgerContentContainer {
    
    @inlinable
    var hamburgerContainer: IQHamburgerContainer? {
        return self.parent as? IQHamburgerContainer
    }
    
}

public protocol IQHamburgerMenuContainer : IQHamburgerContentContainer {
    
    var hamburgerSize: QFloat { get }
    var hamburgerLimit: QFloat { get }
    
}
