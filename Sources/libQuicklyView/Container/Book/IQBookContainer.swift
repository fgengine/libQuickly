//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQBookContainer : IQContainer, IQContainerParentable {
    
    var backward: IQBookContentContainer? { get }
    var current: IQBookContentContainer? { get }
    var forward: IQBookContentContainer? { get }
    var animationVelocity: Float { set get }
    #if os(iOS)
    var interactiveLimit: Float { set get }
    #endif
    
    func set(current: IQBookContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public protocol IQBookContentContainer : IQContainer, IQContainerParentable {
    
    var bookIdentifier: Any { get }
    
}

public extension IQBookContainer {
    
    @inlinable
    func set(current: IQBookContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(current: current, animated: animated, completion: completion)
    }
    
}

public extension IQBookContentContainer {
    
    var bookContainer: IQBookContainer? {
        return self.parent as? IQBookContainer
    }
    
}
