//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQBookScreen : IQScreen {
    
    func initialContainer() -> IQBookContentContainer
    
    func backwardContainer(_ current: IQBookContentContainer) -> IQBookContentContainer?
    
    func forwardContainer(_ current: IQBookContentContainer) -> IQBookContentContainer?
    
    func change(current: IQBookContentContainer)
    
    func beginInteractive()
    
    func finishInteractiveToBackward()
    
    func finishInteractiveToForward()
    
    func cancelInteractive()
    
}

public extension IQBookScreen {
    
    func change(current: IQBookContentContainer) {
    }
    
    func beginInteractive() {
    }
    
    func finishInteractiveToBackward() {
    }
    
    func finishInteractiveToForward() {
    }
    
    func cancelInteractive() {
    }
    
}

public extension IQBookScreen {
    
    @inlinable
    var bookContainer: IQBookContainer? {
        return self.container as? IQBookContainer
    }
    
}
