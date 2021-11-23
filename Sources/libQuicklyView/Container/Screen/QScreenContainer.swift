//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QScreenContainer< Screen : IQScreen & IQScreenViewable > : IQScreenContainer, IQContainerScreenable {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            guard self.parent !== oldValue else { return }
            guard self.isPresented == true else { return }
            self.didChangeInsets()
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
        return self._view
    }
    public private(set) var screen: Screen
    
    private var _view: QCustomView< Layout >
    
    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
        self._view = QCustomView(
            contentLayout: Layout()
        )
        self._init()
    }
    
    deinit {
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        return self.inheritedInsets(interactive: interactive)
    }
    
    public func didChangeInsets() {
        self.screen.didChangeInsets()
    }
    
    public func activate() -> Bool {
        guard self.isPresented == true else { return false }
        return self.screen.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
        if self._view.contentLayout.item == nil {
            self._view.contentLayout.item = QLayoutItem(view: self.screen.view)
        }
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

extension QScreenContainer : IQRootContentContainer {
}

extension QScreenContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
    public var stackBarView: IQStackBarView {
        return self.screen.stackBarView
    }
    
    public var stackBarVisibility: Float {
        return max(0, min(self.screen.stackBarVisibility, 1))
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

extension QScreenContainer : IQBookContentContainer where Screen : IQScreenBookable {
    
    public var bookIdentifier: Any {
        return self.screen.bookIdentifier
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
    
    public var modalSheetInset: QInset? {
        switch self.screen.modalPresentation {
        case .simple: return nil
        case .sheet(let info): return info.inset
        }
    }
    
    public var modalSheetBackgroundView: (IQView & IQViewAlphable)? {
        switch self.screen.modalPresentation {
        case .simple: return nil
        case .sheet(let info): return info.backgroundView
        }
    }
    
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

private extension QScreenContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var item: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        
        init() {
        }
        
        func layout(bounds: QRect) -> QSize {
            if let item = self.item {
                item.frame = bounds
            }
            return bounds.size
        }
        
        func size(available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            guard let item = self.item else { return [] }
            return [ item ]
        }
        
    }
    
}
