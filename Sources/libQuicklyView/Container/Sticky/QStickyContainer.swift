//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStickyContainer : IQStickyContainer {
    
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
    public var contentContainer: IQStickyContentContainer {
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
    public var accessoryContainer: IQStickyAccessoryContainer {
        set(value) {
            guard self._accessoryContainer !== value else { return }
            if self.isPresented == true {
                self._accessoryContainer.prepareHide(interactive: false)
                self._accessoryContainer.finishHide(interactive: false)
            }
            self._accessoryContainer.parent = nil
            self._accessoryContainer = value
            self._accessoryContainer.parent = self
            self._rootLayout.accessoryItem = QLayoutItem(view: self._accessoryContainer.view)
            self._rootLayout.accessorySize = self._accessoryContainer.stickySize
            if self.isPresented == true {
                self._accessoryContainer.prepareShow(interactive: false)
                self._accessoryContainer.finishShow(interactive: false)
            }
            self.didChangeInsets()
        }
        get { return self._accessoryContainer }
    }
    
    private var _rootLayout: RootLayout
    private var _rootView: QCustomView< RootLayout >
    private var _contentContainer: IQStickyContentContainer
    private var _accessoryContainer: IQStickyAccessoryContainer
    
    public init(
        contentContainer: IQStickyContentContainer,
        accessoryContainer: IQStickyAccessoryContainer
    ) {
        self.isPresented = false
        self._rootLayout = RootLayout(
            contentItem: QLayoutItem(view: contentContainer.view),
            accessoryItem: QLayoutItem(view: accessoryContainer.view),
            accessorySize: accessoryContainer.stickySize
        )
        self._rootView = QCustomView(
            name: "QStickyContainer-RootView",
            contentLayout: self._rootLayout
        )
        self._contentContainer = contentContainer
        self._accessoryContainer = accessoryContainer
        self._init()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if self._contentContainer === container {
            let accessorySize = self._accessoryContainer.stickySize
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom + accessorySize
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        self._contentContainer.didChangeInsets()
        self._accessoryContainer.didChangeInsets()
    }
    
    public func activate() -> Bool {
        return self._contentContainer.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self._contentContainer.prepareShow(interactive: interactive)
        self._accessoryContainer.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self._contentContainer.finishShow(interactive: interactive)
        self._accessoryContainer.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self._contentContainer.cancelShow(interactive: interactive)
        self._accessoryContainer.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self._contentContainer.prepareHide(interactive: interactive)
        self._accessoryContainer.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self._contentContainer.finishHide(interactive: interactive)
        self._accessoryContainer.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self._contentContainer.cancelHide(interactive: interactive)
        self._accessoryContainer.cancelHide(interactive: interactive)
    }

}

private extension QStickyContainer {
    
    func _init() {
        self._contentContainer.parent = self
        self._accessoryContainer.parent = self
    }
    
}

private extension QStickyContainer {
    
    class RootLayout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var contentItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var accessoryItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var accessorySize: Float {
            didSet { self.setNeedForceUpdate() }
        }
        
        init(
            contentItem: QLayoutItem,
            accessoryItem: QLayoutItem,
            accessorySize: Float
        ) {
            self.contentItem = contentItem
            self.accessoryItem = accessoryItem
            self.accessorySize = accessorySize
        }
        
        func invalidate(item: QLayoutItem) {
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            self.accessoryItem.frame = QRect(
                bottomLeft: bounds.bottomLeft,
                size: QSize(
                    width: bounds.size.width,
                    height: self.accessorySize
                )
            )
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            return [ self.contentItem, self.accessoryItem ]
        }
        
    }
    
}

extension QStickyContainer : IQRootContentContainer {
}
