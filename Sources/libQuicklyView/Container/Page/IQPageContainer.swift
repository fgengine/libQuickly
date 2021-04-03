//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPageContainer : IQContainer, IQContainerParentable {
    
    var barView: IQPageBarView { get }
    var barSize: QFloat { get }
    var barVisibility: QFloat { get }
    var barHidden: Bool { get }
    var containers: [IQPageContentContainer] { get }
    var backwardContainer: IQPageContentContainer? { get }
    var currentContainer: IQPageContentContainer? { get }
    var forwardContainer: IQPageContentContainer? { get }
    var animationVelocity: QFloat { set get }
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    #endif
    
    func updateBar(animated: Bool, completion: (() -> Void)?)
    
    func update(container: IQPageContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(containers: [IQPageContentContainer], current: IQPageContentContainer?, animated: Bool, completion: (() -> Void)?)
    func set(current: IQPageContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQPageContainer {
    
    @inlinable
    func update(container: IQPageContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.update(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func set(containers: [IQPageContentContainer], current: IQPageContentContainer? = nil, animated: Bool = false, completion: (() -> Void)? = nil) {
        self.set(containers: containers, current: current, animated: animated, completion: completion)
    }
    
    @inlinable
    func set(current: IQPageContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(current: current, animated: animated, completion: completion)
    }
    
}

public protocol IQPageContentContainer : IQContainer, IQContainerParentable {
    
    var pageContainer: IQPageContainer? { get }
    
    var pageItemView: IQBarItemView { get }
    
}

public extension IQPageContentContainer {
    
    @inlinable
    var pageContainer: IQPageContainer? {
        return self.parent as? IQPageContainer
    }
    
    @inlinable
    func updatePageBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard let pageContainer = self.pageContainer else {
            completion?()
            return
        }
        pageContainer.updateBar(animated: animated, completion: completion)
    }
    
}
