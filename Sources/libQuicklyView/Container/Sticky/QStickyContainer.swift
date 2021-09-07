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
            guard self.parent !== oldValue else { return }
            guard self.isPresented == true else { return }
            self.didChangeInsets()
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
        return self._view
    }
    public private(set) var screen: Screen
    public private(set) var overlayView: IQBarView {
        set(value) {
            guard self._overlayView !== value else { return }
            self._view.contentLayout.overlayItem = QLayoutItem(view: self._overlayView)
        }
        get { return self._overlayView }
    }
    public private(set) var overlayHidden: Bool {
        set(value) { self._view.contentLayout.overlayHidden = value }
        get { return self._view.contentLayout.overlayHidden }
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
            self._view.contentLayout.contentItem = QLayoutItem(view: self._contentContainer.view)
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
    
    private var _view: QCustomView< Layout >
    private var _overlayView: IQBarView
    private var _contentContainer: IQContainer & IQContainerParentable
    
    public init(
        screen: Screen,
        contentContainer: IQContainer & IQContainerParentable
    ) {
        self.screen = screen
        self.isPresented = false
        self._view = QCustomView(
            contentLayout: Layout(
                contentItem: QLayoutItem(view: contentContainer.view),
                overlayItem: QLayoutItem(view: screen.stickyView),
                overlayHidden: screen.stickyHidden
            )
        )
        self._overlayView = screen.stickyView
        self._contentContainer = contentContainer
        self._init()
    }
    
    deinit {
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        let inheritedInsets = self.inheritedInsets(interactive: interactive)
        if self._contentContainer === container, let overlaySize = self._view.contentLayout.overlaySize {
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom + overlaySize.height
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets(interactive: true)
        self._overlayView.safeArea(QInset(top: 0, left: inheritedInsets.left, right: inheritedInsets.right, bottom: 0))
        self._view.contentLayout.overlayInset = inheritedInsets.bottom
        self._contentContainer.didChangeInsets()
    }
    
    public func activate() -> Bool {
        return self._contentContainer.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
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
        self._view.contentLayout.overlayHidden = self.screen.stickyHidden
        self.didChangeInsets()
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
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var contentItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var overlayItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var overlayInset: Float {
            didSet { self.setNeedUpdate() }
        }
        var overlayHidden: Bool {
            didSet { self.setNeedUpdate() }
        }
        var overlaySize: QSize?
        
        init(
            contentItem: QLayoutItem,
            overlayItem: QLayoutItem,
            overlayInset: Float = 0,
            overlayHidden: Bool
        ) {
            self.contentItem = contentItem
            self.overlayItem = overlayItem
            self.overlayInset = overlayInset
            self.overlayHidden = overlayHidden
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            if self.overlayHidden == false {
                let overlaySize = self.overlayItem.size(bounds.size)
                self.overlayItem.frame = QRect(
                    bottomLeft: bounds.bottomLeft,
                    size: QSize(
                        width: bounds.size.width,
                        height: self.overlayInset + overlaySize.height
                    )
                )
                self.overlaySize = overlaySize
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
