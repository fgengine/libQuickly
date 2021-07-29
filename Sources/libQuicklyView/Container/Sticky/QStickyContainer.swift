//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStickyContainer< Screen : IQStickyScreen > : IQStickyContainer {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var shouldInteractive: Bool {
        return self.contentContainer.shouldInteractive
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self.contentContainer.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self.contentContainer.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self.contentContainer.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self.contentContainer.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._rootView
    }
    public private(set) var screen: Screen
    public private(set) var overlayView: IQBarView {
        set(value) {
            guard self._overlayView !== value else { return }
            self._rootLayout.overlayItem = QLayoutItem(view: self._overlayView)
        }
        get { return self._overlayView }
    }
    public private(set) var overlaySize: Float {
        set(value) { self._rootLayout.overlaySize = value }
        get { return self._rootLayout.overlaySize }
    }
    public private(set) var overlayHidden: Bool {
        set(value) { self._rootLayout.overlayHidden = value }
        get { return self._rootLayout.overlayHidden }
    }
    public var contentContainer: IQContainer & IQContainerParentable {
        set(value) {
            guard self._contentContainer !== value else { return }
            if self.isPresented == true {
                self._contentContainer.prepareHide(interactive: false)
                self._contentContainer.finishHide(interactive: false)
            }
            self._contentContainer.parent = nil
            self._contentContainer = value
            self._contentContainer.parent = self
            self._rootLayout.contentItem = QLayoutItem(view: self._contentContainer.view)
            if self.isPresented == true {
                self._contentContainer.prepareShow(interactive: false)
                self._contentContainer.finishShow(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            self.didChangeInsets()
        }
        get { return self._contentContainer }
    }
    
    private var _rootLayout: RootLayout
    private var _rootView: QCustomView< RootLayout >
    private var _overlayView: IQBarView
    private var _contentContainer: IQContainer & IQContainerParentable
    
    public init(
        screen: Screen,
        contentContainer: IQContainer & IQContainerParentable
    ) {
        self.screen = screen
        self.isPresented = false
        self._rootLayout = RootLayout(
            contentItem: QLayoutItem(view: contentContainer.view),
            overlayItem: QLayoutItem(view: screen.stickyView),
            overlaySize: screen.stickySize,
            overlayHidden: screen.stickyHidden
        )
        self._rootView = QCustomView(
            contentLayout: self._rootLayout
        )
        self._overlayView = screen.stickyView
        self._contentContainer = contentContainer
        self._init()
    }
    
    deinit {
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if self._contentContainer === container {
            let overlaySize = self._rootLayout.overlaySize
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom + overlaySize
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets
        self._overlayView.safeArea(QInset(top: 0, left: inheritedInsets.left, right: inheritedInsets.right, bottom: inheritedInsets.bottom))
        self._rootLayout.overlayInset = inheritedInsets.bottom
        self._contentContainer.didChangeInsets()
    }
    
    public func activate() -> Bool {
        return self._contentContainer.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.screen.prepareShow(interactive: interactive)
        self._contentContainer.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.screen.finishShow(interactive: interactive)
        self._contentContainer.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.screen.cancelShow(interactive: interactive)
        self._contentContainer.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.screen.prepareHide(interactive: interactive)
        self._contentContainer.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.screen.finishHide(interactive: interactive)
        self._contentContainer.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.screen.cancelHide(interactive: interactive)
        self._contentContainer.cancelHide(interactive: interactive)
    }
    
    public func updateOverlay(animated: Bool, completion: (() -> Void)?) {
        self._rootLayout.overlaySize = self.screen.stickySize
        self._rootLayout.overlayHidden = self.screen.stickyHidden
    }

}

private extension QStickyContainer {
    
    func _init() {
        self.screen.container = self
        self._contentContainer.parent = self
        self.screen.setup()
    }
    
}

private extension QStickyContainer {
    
    class RootLayout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var contentItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var overlayItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var overlayInset: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var overlayHidden: Bool {
            didSet { self.setNeedForceUpdate() }
        }
        var overlaySize: Float {
            didSet { self.setNeedForceUpdate() }
        }
        
        init(
            contentItem: QLayoutItem,
            overlayItem: QLayoutItem,
            overlayInset: Float = 0,
            overlaySize: Float,
            overlayHidden: Bool
        ) {
            self.contentItem = contentItem
            self.overlayItem = overlayItem
            self.overlayInset = overlayInset
            self.overlaySize = overlaySize
            self.overlayHidden = overlayHidden
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            if self.overlayHidden == false {
                self.overlayItem.frame = QRect(
                    bottomLeft: bounds.bottomLeft,
                    size: QSize(
                        width: bounds.size.width,
                        height: self.overlayInset + self.overlaySize
                    )
                )
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            if self.overlayHidden == false {
                return [ self.contentItem, self.overlayItem ]
            }
            return [ self.contentItem ]
        }
        
    }
    
}

extension QStickyContainer : IQRootContentContainer {
}
