//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QStackWireframe< Screen : IQScreen > : IQWireframe {
    
    public private(set) var container: QStackContainer< Screen >
    
    public init(screen: Screen) {
        self.container = QStackContainer(screen: screen)
    }
    
    public func set< Screen: IQScreen & IQScreenViewable & IQScreenStackable >(
        screen: Screen,
        animated: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        self.container.set(
            container: QScreenContainer(screen: screen),
            animated: animated,
            completion: completion
        )
    }
    
    public func push< Screen: IQScreen & IQScreenViewable & IQScreenStackable >(
        screen: Screen,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.container.push(
            container: QScreenContainer(screen: screen),
            animated: animated,
            completion: completion
        )
    }
    
    public func pop(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.container.pop(animated: animated, completion: completion)
    }
    
    public func popTo< Screen: IQScreen & IQScreenStackable >(
        screen: Screen,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let container = screen.container as? IQStackContentContainer else {
            completion?()
            return
        }
        self.container.popTo(
            container: container,
            animated: animated,
            completion: completion
        )
    }
    
    public func popToRoot(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.container.popToRoot(
            animated: animated,
            completion: completion
        )
    }
    
}
