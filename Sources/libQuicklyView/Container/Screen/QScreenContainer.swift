//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QScreenContainer< Screen : IQScreen & IQScreenViewable > : IQScreenContainer {
    
    public weak var parentContainer: IQContainer? {
        didSet(oldValue) {
            if self.parentContainer !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self.screen.view
    }
    public private(set) var screen: Screen

    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
    }
    
    public func insets(of container: IQContainer) -> QInset {
        return self.inheritedInsets
    }
    
    public func didChangeInsets() {
        self.screen.didChangeInsets()
    }
    
    public func willShow(interactive: Bool) {
        self.screen.willShow(interactive: interactive)
    }
    
    public func didShow(interactive: Bool, finished: Bool) {
        self.isPresented = true
        self.screen.didShow(interactive: interactive, finished: finished)
    }
    
    public func willHide(interactive: Bool) {
        self.screen.willHide(interactive: interactive)
    }
    
    public func didHide(interactive: Bool, finished: Bool) {
        self.isPresented = false
        self.screen.didHide(interactive: interactive, finished: finished)
    }
    
}

#if os(iOS)

extension QScreenContainer where Screen : IQScreenStatusable {
    
    public var statusBarHidden: Bool {
        return self.screen.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self.screen.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self.screen.statusBarAnimation
    }
    
}

extension QScreenContainer where Screen : IQScreenOrientable {
    
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self.screen.supportedOrientations
    }
    
}

#endif

extension QScreenContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
    public var stackBarSize: QFloat {
        return self.screen.stackBarSize
    }
    
    public var stackBarVisibility: QFloat {
        return self.screen.stackBarVisibility
    }
    
    public var stackBarHidden: Bool {
        return self.screen.stackBarHidden
    }
    
    public var stackBarItemView: IQView {
        return self.screen.stackBarItemView
    }
    
}
