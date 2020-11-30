//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQView : AnyObject {
    
    var parentLayout: IQLayout? { get }
    var item: IQLayoutItem? { set get }
    var alpha: QFloat { set get }
    var isLoaded: Bool { get }
    var isAppeared: Bool { get }
    var native: QNativeView { get }
    
    func onAppear(to layout: IQLayout)
    func onDisappear()

    func size(_ available: QSize) -> QSize
    
}
