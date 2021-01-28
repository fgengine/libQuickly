//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStickyContainer : IQStickyContainer {
    
    public weak var parentContainer: IQContainer? {
        didSet(oldValue) {
            if self.parentContainer !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self.contentContainer?.statusBarHidden ?? false
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self.contentContainer?.statusBarStyle ?? .default
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self.contentContainer?.statusBarAnimation ?? .fade
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self.contentContainer?.supportedOrientations ?? .all
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._rootView
    }
    public var contentContainer: IQStickyContentContainer? {
        set(value) {
            guard self._contentContainer !== value else { return }
            if let contentContainer = self.contentContainer {
                if self.isPresented == true {
                    contentContainer.prepareHide(interactive: false)
                    contentContainer.finishHide(interactive: false)
                }
                contentContainer.stickyContainer = nil
            }
            self._contentContainer = value
            if let contentContainer = self.contentContainer {
                self._rootLayout.contentContainerItem = QLayoutItem(view: contentContainer.view)
                contentContainer.stickyContainer = self
                if self.isPresented == true {
                    contentContainer.prepareShow(interactive: false)
                    contentContainer.finishShow(interactive: false)
                }
            } else {
                self._rootLayout.contentContainerItem = nil
            }
            self.didChangeInsets()
        }
        get { return self._contentContainer }
    }
    public var accessoryContainer: IQStickyAccessoryContainer? {
        set(value) {
            guard self._accessoryContainer !== value else { return }
            if let accessoryContainer = self.accessoryContainer {
                if self.isPresented == true {
                    accessoryContainer.prepareHide(interactive: false)
                    accessoryContainer.finishHide(interactive: false)
                }
                accessoryContainer.stickyContainer = nil
            }
            self._accessoryContainer = value
            if let accessoryContainer = self.accessoryContainer {
                self._rootLayout.accessoryContainerItem = QLayoutItem(view: accessoryContainer.view)
                self._rootLayout.accessoryContainerSize = accessoryContainer.stickySize
                accessoryContainer.stickyContainer = self
                if self.isPresented == true {
                    accessoryContainer.prepareShow(interactive: false)
                    accessoryContainer.finishShow(interactive: false)
                }
            } else {
                self._rootLayout.accessoryContainerItem = nil
                self._rootLayout.accessoryContainerSize = nil
            }
            self.didChangeInsets()
        }
        get { return self._accessoryContainer }
    }
    
    private var _rootLayout: RootLayout
    private var _rootView: QCustomView
    private var _contentContainer: IQStickyContentContainer?
    private var _accessoryContainer: IQStickyAccessoryContainer?
    
    public init() {
        self.isPresented = false
        self._rootLayout = RootLayout()
        self._rootView = QCustomView(layout: self._rootLayout)
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if self._contentContainer === container, let accessoryContainer = self._accessoryContainer {
            let accessorySize = accessoryContainer.stickySize
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
        self._contentContainer?.didChangeInsets()
        self._accessoryContainer?.didChangeInsets()
    }
    
    public func prepareShow(interactive: Bool) {
        self._contentContainer?.prepareShow(interactive: interactive)
        self._accessoryContainer?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self._contentContainer?.finishShow(interactive: interactive)
        self._accessoryContainer?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self._contentContainer?.cancelShow(interactive: interactive)
        self._accessoryContainer?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self._contentContainer?.prepareHide(interactive: interactive)
        self._accessoryContainer?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self._contentContainer?.finishHide(interactive: interactive)
        self._accessoryContainer?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self._contentContainer?.cancelHide(interactive: interactive)
        self._accessoryContainer?.cancelHide(interactive: interactive)
    }

}

private extension QStickyContainer {
    
    class RootLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var contentContainerItem: IQLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var accessoryContainerItem: IQLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var accessoryContainerSize: QFloat? {
            didSet { self.setNeedUpdate() }
        }
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let item = self.contentContainerItem {
                items.append(item)
            }
            if let item = self.accessoryContainerItem {
                items.append(item)
            }
            return items
        }
        
        func layout(bounds: QRect) -> QSize {
            if let item = self.contentContainerItem {
                item.frame = bounds
            }
            if let item = self.accessoryContainerItem, let size = self.accessoryContainerSize {
                item.frame = QRect(
                    bottomLeft: bounds.bottomLeft,
                    size: QSize(
                        width: bounds.size.width,
                        height: size
                    )
                )
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
    }
    
}

extension QStickyContainer : IQRootContentContainer {
}
