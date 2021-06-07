//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenStackable : AnyObject {
    
    associatedtype StackBar : IQStackBarView
    
    var stackBarView: StackBar { get }
    var stackBarSize: Float { get }
    var stackBarVisibility: Float { get }
    var stackBarHidden: Bool { get }
    
}

public extension IQScreenStackable {
    
    var stackBarSize: Float {
        return 50
    }
    
    var stackBarVisibility: Float {
        return 1
    }
    
    var stackBarHidden: Bool {
        return false
    }
    
}

public extension IQScreenStackable where Self : IQScreen {
    
    @inlinable
    var stackContentContainer: IQStackContentContainer? {
        guard let contentContainer = self.container as? IQStackContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var stackContainer: IQStackContainer? {
        return self.stackContentContainer?.stackContainer
    }
    
    @inlinable
    func updateStackContainer(animated: Bool, completion: (() -> Void)? = nil) {
        guard let contentContainer = self.container as? IQStackContentContainer else { return }
        guard let container = contentContainer.stackContainer else { return }
        container.update(container: contentContainer, animated: animated, completion: completion)
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
