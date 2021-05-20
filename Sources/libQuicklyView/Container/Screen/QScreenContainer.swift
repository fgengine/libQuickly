//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QScreenContainer< Screen : IQScreen & IQScreenViewable > : IQScreenContainer {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var shouldInteractive: Bool {
        return self.screen.shouldInteractive
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        guard let screen = self.screen as? IQScreenStatusable else { return false }
        return screen.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        guard let screen = self.screen as? IQScreenStatusable else { return .default }
        return screen.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        guard let screen = self.screen as? IQScreenStatusable else { return .fade }
        return screen.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        guard let screen = self.screen as? IQScreenOrientable else { return .all }
        return screen.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self.screen.view
    }
    public private(set) var screen: Screen

    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
        self._init()
    }
    
    deinit {
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        return self.inheritedInsets
    }
    
    public func didChangeInsets() {
        self.screen.didChangeInsets()
    }
    
    public func activate() -> Bool {
        return self.screen.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.screen.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.screen.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.screen.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.screen.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.screen.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.screen.cancelHide(interactive: interactive)
    }
    
}

private extension QScreenContainer {
    
    func _init() {
        self.screen.container = self
        self.screen.setup()
    }
    
}

extension QScreenContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
    public var stackBarView: IQStackBarView {
        return self.screen.stackBarView
    }
    
    public var stackBarSize: Float {
        return self.screen.stackBarSize
    }
    
    public var stackBarVisibility: Float {
        return self.screen.stackBarVisibility
    }
    
    public var stackBarHidden: Bool {
        return self.screen.stackBarHidden
    }
    
}

extension QScreenContainer : IQGroupContentContainer where Screen : IQScreenGroupable {
    
    public var groupItemView: IQBarItemView {
        return self.screen.groupItemView
    }
    
}

extension QScreenContainer : IQPageContentContainer where Screen : IQScreenPageable {
    
    public var pageItemView: IQBarItemView {
        return self.screen.pageItemView
    }
    
}

extension QScreenContainer : IQHamburgerContentContainer {
}

extension QScreenContainer : IQHamburgerMenuContainer where Screen : IQScreenHamburgerable {
    
    public var hamburgerSize: Float {
        return self.screen.hamburgerSize
    }
    
    public var hamburgerLimit: Float {
        return self.screen.hamburgerLimit
    }
    
}

extension QScreenContainer : IQModalContentContainer where Screen : IQScreenModalable {
}

extension QScreenContainer : IQDialogContentContainer where Screen : IQScreenDialogable {
    
    public var dialogWidth: QDialogContentContainerSize {
        return self.screen.dialogWidth
    }
    
    public var dialogHeight: QDialogContentContainerSize {
        return self.screen.dialogHeight
    }
    
    public var dialogAlignment: QDialogContentContainerAlignment {
        return self.screen.dialogAlignment
    }
    
}

extension QScreenContainer : IQPushContentContainer where Screen : IQScreenPushable {
    
    public var pushDuration: TimeInterval? {
        return self.screen.pushDuration
    }
    
}
