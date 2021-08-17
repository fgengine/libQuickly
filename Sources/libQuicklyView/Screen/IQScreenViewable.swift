//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenViewable : AnyObject {
    
    associatedtype View : IQView
    
    var view: View { get }
    
    func didChangeInsets()
    
}

public extension IQScreenViewable {
    
    func didChangeInsets() {
    }
    
}

public extension IQScreenViewable where Self : IQScreen, View : IQScrollView {
    
    func didChangeInsets() {
        self.view.contentInset = self.inheritedInsets()
    }
    
    func activate() -> Bool {
        self.view.scrollToTop()
        return true
    }
    
}
