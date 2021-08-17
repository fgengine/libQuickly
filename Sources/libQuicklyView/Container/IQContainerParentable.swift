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
    
    func inheritedInsets(interactive: Bool) -> QInset {
        guard let parent = self.parent else { return .zero }
        self.view.layoutIfNeeded()
        return parent.insets(of: self, interactive: interactive)
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
