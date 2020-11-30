//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public protocol IQContainerParentable : AnyObject {
    
    var parentContainer: IQContainer? { set get }
    
}

public extension IQContainerParentable where Self : IQContainer {
    
    var inheritedInsets: QInset {
        return self.parentContainer?.insets(of: self) ?? QInset()
    }
    
    #if os(iOS)
    
    func setNeedUpdateStatusBar() {
        self.parentContainer?.setNeedUpdateStatusBar()
    }
    
    func setNeedUpdateOrientations() {
        self.parentContainer?.setNeedUpdateOrientations()
    }
    
    #endif
    
}
