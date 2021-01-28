//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGroupContainer : IQContainer, IQContainerParentable {
    
    var containers: [IQGroupContentContainer] { get }
    var currentContainer: IQGroupContentContainer? { get }
    
    func update(container: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(containers: [IQGroupContentContainer], current: IQGroupContentContainer?, animated: Bool, completion: (() -> Void)?)
    func set(current: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQGroupContainer {
    
    func update(container: IQGroupContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.update(container: container, animated: animated, completion: completion)
    }
    
    func set(containers: [IQGroupContentContainer], current: IQGroupContentContainer? = nil, animated: Bool = false, completion: (() -> Void)? = nil) {
        self.set(containers: containers, current: current, animated: animated, completion: completion)
    }
    
    func set(current: IQGroupContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(current: current, animated: animated, completion: completion)
    }
    
}

public protocol IQGroupContentContainer : IQContainer {
    
    var groupContainer: IQGroupContainer? { set get }
    
    var groupBarSize: QFloat { get }
    var groupBarItemView: IQView & IQViewSelectable { get }
    
}

public extension IQGroupContentContainer where Self : IQContainerParentable {
    
    var groupContainer: IQGroupContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQGroupContainer }
    }
    
}
