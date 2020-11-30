//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQAccessoryView : AnyObject {
    
    var parentView: IQView? { get }
    var alpha: QFloat { set get }
    var isLoaded: Bool { get }
    var isAppeared: Bool { get }
    var native: QNativeView { get }
    
    func onAppear(to view: IQView)
    func onDisappear()

    func size(_ available: QSize) -> QSize
    
}
