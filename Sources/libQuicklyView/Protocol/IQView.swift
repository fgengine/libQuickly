//
//  libQuicklyView
//

import Foundation

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

public protocol IQSpinnerView : IQView {
    
    var isAnimating: Bool { set get }
    
}

public protocol IQProgressView : IQView {

    var progress: QFloat { set get }
    
}
