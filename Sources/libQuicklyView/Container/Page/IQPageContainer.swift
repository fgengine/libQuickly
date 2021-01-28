//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPageContainer : IQContainer, IQContainerParentable {
    
    var barView: IQPageBarView { get }
    var barSize: QFloat { get }
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQPageContentContainer] { get }
    var backwardContainer: IQPageContentContainer? { get }
    var currentContainer: IQPageContentContainer? { get }
    var forwardContainer: IQPageContentContainer? { get }
    
    func updateBar(animated: Bool, completion: (() -> Void)?)
    
    func update(container: IQPageContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(containers: [IQPageContentContainer], current: IQPageContentContainer?, animated: Bool, completion: (() -> Void)?)
    func set(current: IQPageContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQPageContainer {
    
    func update(container: IQPageContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.update(container: container, animated: animated, completion: completion)
    }
    
    func set(containers: [IQPageContentContainer], current: IQPageContentContainer? = nil, animated: Bool = false, completion: (() -> Void)? = nil) {
        self.set(containers: containers, current: current, animated: animated, completion: completion)
    }
    
    func set(current: IQPageContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(current: current, animated: animated, completion: completion)
    }
    
}

public protocol IQPageContentContainer : IQContainer {
    
    var pageContainer: IQPageContainer? { set get }
    
    var pageItemView: IQView & IQViewSelectable { get }
    
}

public extension IQPageContentContainer where Self : IQContainerParentable {
    
    var pageContainer: IQPageContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQPageContainer }
    }
    
    func updatePageBar(animated: Bool, completion: (() -> Void)? = nil) {
        self.pageContainer?.updateBar(animated: animated, completion: completion)
    }
    
}
