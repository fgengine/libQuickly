//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreen : AnyObject {
    
    var container: IQContainer? { set get }
    
    func prepareShow(interactive: Bool)
    func finishShow(interactive: Bool)
    func cancelShow(interactive: Bool)
    
    func prepareHide(interactive: Bool)
    func finishHide(interactive: Bool)
    func cancelHide(interactive: Bool)
    
}

public extension IQScreen {
    
    var isPresented: Bool {
        return self.container?.isPresented ?? false
    }
    
    var inheritedInsets: QInset {
        return self.container?.inheritedInsets ?? QInset()
    }
    
    func prepareShow(interactive: Bool) {
    }
    
    func finishShow(interactive: Bool) {
    }
    
    func cancelShow(interactive: Bool) {
    }
    
    func prepareHide(interactive: Bool) {
    }
    
    func finishHide(interactive: Bool) {
    }
    
    func cancelHide(interactive: Bool) {
    }
    
}

#if os(iOS)

import UIKit

public protocol IQScreenStatusable : AnyObject {
    
    var statusBarHidden: Bool { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var statusBarAnimation: UIStatusBarAnimation { get }
    
}

public extension IQScreenStatusable where Self : IQScreen {
    
    func setNeedUpdateStatusBar() {
        self.container?.setNeedUpdateStatusBar()
    }
    
}

public protocol IQScreenOrientable : AnyObject {
    
    var supportedOrientations: UIInterfaceOrientationMask { get }
    
}

public extension IQScreenOrientable where Self : IQScreen {
    
    func setNeedUpdateOrientations() {
        self.container?.setNeedUpdateOrientations()
    }
    
}

#endif
