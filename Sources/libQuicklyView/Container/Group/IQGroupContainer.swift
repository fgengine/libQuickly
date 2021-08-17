//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGroupContainer : IQContainer, IQContainerParentable {
    
    var barView: IQGroupBarView { get }
    var barVisibility: Float { get }
    var barHidden: Bool { get }
    var containers: [IQGroupContentContainer] { get }
    var backwardContainer: IQGroupContentContainer? { get }
    var currentContainer: IQGroupContentContainer? { get }
    var forwardContainer: IQGroupContentContainer? { get }
    var animationVelocity: Float { set get }
    
    func updateBar(animated: Bool, completion: (() -> Void)?)
    
    func update(container: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(containers: [IQGroupContentContainer], current: IQGroupContentContainer?, animated: Bool, completion: (() -> Void)?)
    func set(current: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQGroupContainer {
    
    @inlinable
    func update(container: IQGroupContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.update(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func set(containers: [IQGroupContentContainer], current: IQGroupContentContainer? = nil, animated: Bool = false, completion: (() -> Void)? = nil) {
        self.set(containers: containers, current: current, animated: animated, completion: completion)
    }
    
    @inlinable
    func set(current: IQGroupContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(current: current, animated: animated, completion: completion)
    }
    
}

public protocol IQGroupContentContainer : IQContainer, IQContainerParentable {
    
    var groupContainer: IQGroupContainer? { get }
    
    var groupItemView: IQBarItemView { get }
    
}

public extension IQGroupContentContainer {
    
    var groupContainer: IQGroupContainer? {
        return self.parent as? IQGroupContainer
    }
    
    func updateGroupBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard let groupContainer = self.groupContainer else {
            completion?()
            return
        }
        groupContainer.updateBar(animated: animated, completion: completion)
    }
    
}
