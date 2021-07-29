//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public protocol IQContainerParentable : AnyObject {
    
    var parent: IQContainer? { set get }
    
}

public extension IQContainerParentable where Self : IQContainer {
    
    var inheritedInsets: QInset {
        return self.parent?.insets(of: self) ?? .zero
    }
    
    #if os(iOS)
    
    func setNeedUpdateStatusBar() {
        self.parent?.setNeedUpdateStatusBar()
    }
    
    func setNeedUpdateOrientations() {
        self.parent?.setNeedUpdateOrientations()
    }
    
    #endif
    
}
