//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public protocol IQContainer : AnyObject {
    
    var inheritedInsets: QInset { get }
    #if os(iOS)
    var statusBarHidden: Bool { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var statusBarAnimation: UIStatusBarAnimation { get }
    var supportedOrientations: UIInterfaceOrientationMask { get }
    #endif
    var isPresented: Bool { get }
    var view: IQView { get }
    
    #if os(iOS)
    func setNeedUpdateStatusBar()
    func setNeedUpdateOrientations()
    #endif
    
    func insets(of container: IQContainer) -> QInset
    func didChangeInsets()
    
    func willShow(interactive: Bool)
    func didShow(interactive: Bool, finished: Bool)

    func willHide(interactive: Bool)
    func didHide(interactive: Bool, finished: Bool)
    
}

public extension IQContainer {
    
    var inheritedInsets: QInset {
        return QInset()
    }
    
    #if os(iOS)
    
    var statusBarHidden: Bool {
        return false
    }
    var statusBarStyle: UIStatusBarStyle {
        return .default
    }
    var statusBarAnimation: UIStatusBarAnimation {
        return .fade
    }
    var supportedOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    #endif
    
}
