//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackContainer : IQContainer, IQContainerParentable {
    
    var rootContainer: IQStackContentContainer { get }
    var containers: [IQStackContentContainer] { get }
    var currentContainer: IQStackContentContainer { get }
    var animationVelocity: Float { set get }
    #if os(iOS)
    var interactiveLimit: Float { set get }
    #endif
    
    func update(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(rootContainer: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func set(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?)
    func push(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func push(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?)
    func push< Wireframe: IQWireframe >(wireframe: Wireframe, animated: Bool, completion: (() -> Void)?) where Wireframe : AnyObject, Wireframe.Container : IQStackContentContainer
    func pop(animated: Bool, completion: (() -> Void)?)
    func popTo(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func popToRoot(animated: Bool, completion: (() -> Void)?)
    
}

public extension IQStackContainer {
    
    @inlinable
    func update(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.update(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func set(rootContainer: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(rootContainer: rootContainer, animated: animated, completion: completion)
    }
    
    @inlinable
    func set(containers: [IQStackContentContainer], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(containers: containers, animated: animated, completion: completion)
    }
    
    @inlinable
    func push(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.push(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func push(containers: [IQStackContentContainer], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.push(containers: containers, animated: animated, completion: completion)
    }
    
    @inlinable
    func push< Wireframe: IQWireframe >(wireframe: Wireframe, animated: Bool = true, completion: (() -> Void)? = nil) where Wireframe : AnyObject, Wireframe.Container : IQStackContentContainer {
        self.push(wireframe: wireframe, animated: animated, completion: completion)
    }
    
    @inlinable
    func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.pop(animated: animated, completion: completion)
    }
    
    @inlinable
    func popTo(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.popTo(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.popToRoot(animated: animated, completion: completion)
    }
    
}

public protocol IQStackContentContainer : IQContainer, IQContainerParentable {
    
    var stackContainer: IQStackContainer? { get }
    
    var stackBarView: IQStackBarView { get }
    var stackBarSize: Float { get }
    var stackBarVisibility: Float { get }
    var stackBarHidden: Bool { get }
    
}

public extension IQStackContentContainer {
    
    @inlinable
    var stackContainer: IQStackContainer? {
        return self.parent as? IQStackContainer
    }
    
    @inlinable
    func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let stackContainer = self.stackContainer else {
            completion?()
            return
        }
        stackContainer.pop(animated: animated, completion: completion)
    }
    
    @inlinable
    func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let stackContainer = self.stackContainer else {
            completion?()
            return
        }
        stackContainer.popToRoot(animated: animated, completion: completion)
    }
    
}
