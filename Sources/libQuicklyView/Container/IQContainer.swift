//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public protocol IQContainer : AnyObject {
    
    var shouldInteractive: Bool { get }
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
    
    func prepareShow(interactive: Bool)
    func finishShow(interactive: Bool)
    func cancelShow(interactive: Bool)
    
    func prepareHide(interactive: Bool)
    func finishHide(interactive: Bool)
    func cancelHide(interactive: Bool)
    
}

public extension IQContainer {
    
    var inheritedInsets: QInset {
        return QInset()
    }
    
}
