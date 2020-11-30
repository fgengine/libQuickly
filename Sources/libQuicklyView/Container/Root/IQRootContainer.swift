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
    var safeArea: QInset { set get }
    var container: IQRootContentContainer? { set get }
    
}

public protocol IQRootContentContainer : IQContainer {
    
    var rootContainer: IQRootContainer? { set get }
    
}

public extension IQRootContentContainer where Self : IQContainerParentable {
    
    var rootContainer: IQRootContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQRootContainer }
    }
    
}
