//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQStackContentContainer] { get }
    var rootContainer: IQStackContentContainer? { get }
    var currentContainer: IQStackContentContainer? { get }
    
    func update(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func set(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?)
    func push(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func push(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool, completion: (() -> Void)?)
    func popTo(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func popToRoot(animated: Bool, completion: (() -> Void)?)
    
}

public extension IQStackContainer {
    
    func update(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.update(container: container, animated: animated, completion: completion)
    }
    
    func set(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(container: container, animated: animated, completion: completion)
    }
    
    func set(containers: [IQStackContentContainer], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.set(containers: containers, animated: animated, completion: completion)
    }
    
    func push(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.push(container: container, animated: animated, completion: completion)
    }
    
    func push(containers: [IQStackContentContainer], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.push(containers: containers, animated: animated, completion: completion)
    }
    
    func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.pop(animated: animated, completion: completion)
    }
    
    func popTo(container: IQStackContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.popTo(container: container, animated: animated, completion: completion)
    }
    
    func popToRoot(animated: Bool, completion: (() -> Void)?) {
        self.popToRoot(animated: animated, completion: completion)
    }
    
}

public protocol IQStackContentContainer : IQContainer {
    
    var stackContainer: IQStackContainer? { set get }
    
    var stackBarView: IQStackBarView { get }
    var stackBarSize: QFloat { get }
    var stackBarVisibility: QFloat { get }
    var stackBarHidden: Bool { get }
    
}

public extension IQStackContentContainer where Self : IQContainerParentable {
    
    var stackContainer: IQStackContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQStackContainer }
    }
    
}
