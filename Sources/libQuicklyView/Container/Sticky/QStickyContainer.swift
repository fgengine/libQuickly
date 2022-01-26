//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStickyContainer< Screen : IQStickyScreen, ContentContainer : IQContainer > : IQStickyContainer where ContentContainer : IQContainerParentable {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            guard self.parent !== oldValue else { return }
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
    public private(set) var overlayVisibility: Float {
        set(value) { self._view.contentLayout.overlayVisibility = value }
        get { return self._view.contentLayout.overlayVisibility }
        
    }
    public private(set) var overlayHidden: Bool {
        set(value) { self._view.contentLayout.overlayHidden = value }
        get { return self._view.contentLayout.overlayHidden }
    }
    public var contentContainer: ContentContainer {
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
    private var _contentContainer: ContentContainer
    
    public init(
        screen: Screen,
        contentContainer: ContentContainer
    ) {
        self.screen = screen
        self.isPresented = false
        self._view = QCustomView(
            contentLayout: Layout(
                contentItem: QLayoutItem(view: contentContainer.view),
                overlayItem: QLayoutItem(view: screen.stickyView),
                overlayVisibility: screen.stickyVisibility,
                overlayHidden: screen.stickyHidden
            )
        )
        self._overlayView = screen.stickyView
        self._contentContainer = contentContainer
        self._init()
        QContainerBarController.shared.add(observer: self)
    }
    
    deinit {
        QContainerBarController.shared.remove(observer: self)
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        let inheritedInsets = self.inheritedInsets(interactive: interactive)
        if self._contentContainer === container, let overlaySize = self._view.contentLayout.overlaySize {
            let bottom: Float
            if self.overlayHidden == false && QContainerBarController.shared.hidden(.sticky) == false {
                if interactive == true {
                    bottom = overlaySize.height * self.overlayVisibility
                } else {
                    bottom = overlaySize.height
                }
            } else {
                bottom = 0
            }
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom + bottom
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets(interactive: true)
        if self.overlayHidden == false {
            self._overlayView.alpha = self.overlayVisibility
        } else {
            self._overlayView.alpha = 0
        }
        self._overlayView.safeArea(QInset(top: 0, left: inheritedInsets.left, right: inheritedInsets.right, bottom: 0))
        self._view.contentLayout.overlayInset = inheritedInsets.bottom
        self._contentContainer.didChangeInsets()
    }
    
    public func activate() -> Bool {
        return self._contentContainer.activate()
    }
    
    public func didChangeAppearance() {
        self.screen.didChangeAppearance()
        self._contentContainer.didChangeAppearance()
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

extension QStickyContainer : IQRootContentContainer {
}

extension QStickyContainer : IQGroupContentContainer where ContentContainer : IQGroupContentContainer {
    
    public var groupItemView: IQBarItemView {
        return self.contentContainer.groupItemView
    }
    
}

extension QStickyContainer : IQStackContentContainer where ContentContainer : IQStackContentContainer {
    
    public var stackBarView: IQStackBarView {
        return self.contentContainer.stackBarView
    }
    
    public var stackBarVisibility: Float {
        return self.contentContainer.stackBarVisibility
    }
    
    public var stackBarHidden: Bool {
        return self.contentContainer.stackBarHidden
    }
    
}

extension QStickyContainer : IQPageContentContainer where ContentContainer : IQPageContentContainer {
    
    public var pageItemView: IQBarItemView {
        return self.contentContainer.pageItemView
    }
    
}

extension QStickyContainer : IQDialogContentContainer where ContentContainer : IQDialogContentContainer {
    
    public var dialogInset: QInset {
        return self.contentContainer.dialogInset
    }
    
    public var dialogWidth: QDialogContentContainerSize {
        return self.contentContainer.dialogWidth
    }
    
    public var dialogHeight: QDialogContentContainerSize {
        return self.contentContainer.dialogHeight
    }
    
    public var dialogAlignment: QDialogContentContainerAlignment {
        return self.contentContainer.dialogAlignment
    }
    
    public var dialogBackgroundView: (IQView & IQViewAlphable)? {
        return self.contentContainer.dialogBackgroundView
    }
    
}

extension QStickyContainer : IQModalContentContainer where ContentContainer : IQModalContentContainer {
    
    public var modalSheetInset: QInset? {
        return self.contentContainer.modalSheetInset
    }
    
    public var modalSheetBackgroundView: (IQView & IQViewAlphable)? {
        return self.contentContainer.modalSheetBackgroundView
    }
    
}

extension QStickyContainer : IQHamburgerContentContainer where ContentContainer : IQHamburgerContentContainer {
}

extension QStickyContainer : IQContainerBarControllerObserver {
    
    public func changed(containerBarController: QContainerBarController) {
        self._view.contentLayout.overlayVisibility = containerBarController.visibility(.sticky)
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
        var overlayVisibility: Float {
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
            overlayVisibility: Float = 0,
            overlayHidden: Bool
        ) {
            self.contentItem = contentItem
            self.overlayItem = overlayItem
            self.overlayInset = overlayInset
            self.overlayVisibility = overlayVisibility
            self.overlayHidden = overlayHidden
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            if self.overlayHidden == false {
                let overlaySize = self.overlayItem.size(available: bounds.size)
                self.overlayItem.frame = QRect(
                    bottomLeft: bounds.bottomLeft,
                    size: QSize(
                        width: bounds.size.width,
                        height: self.overlayInset + (overlaySize.height * self.overlayVisibility)
                    )
                )
                self.overlaySize = overlaySize
            }
            return bounds.size
        }
        
        func size(available: QSize) -> QSize {
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
