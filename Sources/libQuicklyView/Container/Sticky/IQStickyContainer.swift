//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStickyContainer : IQContainer, IQContainerParentable {
    
    var overlayView: IQBarView { get }
    var overlayVisibility: Float { get }
    var overlayHidden: Bool { get }
    
    func updateOverlay(animated: Bool, completion: (() -> Void)?)
    
}

public extension IQStickyContainer {
    
    func updateOverlay(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.updateOverlay(animated: animated, completion: completion)
    }
    
}
