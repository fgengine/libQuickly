//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStickyContainer : IQContainer, IQContainerParentable {
    
    var overlayView: IQBarView { get }
    var overlaySize: Float { get }
    var overlayHidden: Bool { get }
    var contentContainer: IQContainer & IQContainerParentable { set get }
    
    func updateOverlay(animated: Bool, completion: (() -> Void)?)
    
}

public extension IQStickyContainer {
    
    func updateOverlay(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.updateOverlay(animated: animated, completion: completion)
    }
    
}
