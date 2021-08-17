//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQRootContainerDelegate : AnyObject {
    
    #if os(iOS)
    func updateOrientations()
    func updateStatusBar()
    #endif
    
}

public protocol IQRootContainer : IQContainer {
    
    var delegate: IQRootContainerDelegate? { set get }
    var statusBarView: IQStatusBarView? { set get }
    var safeArea: QInset { set get }
    var overlayContainer: IQRootContentContainer? { set get }
    var contentContainer: IQRootContentContainer { set get }
    
}

public protocol IQRootContentContainer : IQContainer, IQContainerParentable {
    
    var rootContainer: IQRootContainer? { get }
    
}

public extension IQRootContentContainer {
    
    @inlinable
    var rootContainer: IQRootContainer? {
        return self.parent as? IQRootContainer
    }
    
}
