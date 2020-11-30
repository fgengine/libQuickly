//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QRootContainer : IQRootContainer {
    
    public weak var delegate: IQRootContainerDelegate?
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self.container?.statusBarHidden ?? false
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self.container?.statusBarStyle ?? .default
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self.container?.statusBarAnimation ?? .fade
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self.container?.supportedOrientations ?? .all
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._view
    }
    public var safeArea: QInset {
        didSet(oldValue) {
            if self.safeArea != oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var container: IQRootContentContainer? {
        willSet {
            if let container = self.container {
                container.willHide(interactive: false)
                container.didHide(interactive: false, finished: true)
                container.rootContainer = nil
            }
        }
        didSet {
            if let container = self.container {
                self._viewLayout.containerItem = QLayoutItem(view: container.view)
                container.rootContainer = self
                container.willShow(interactive: false)
                container.didShow(interactive: false, finished: true)
            }
        }
    }
    
    private var _view: QCustomView
    private var _viewLayout: RootLayout
    
    public init() {
        self.isPresented = false
        self.safeArea = QInset()
        self._viewLayout = RootLayout()
        self._view = QCustomView(layout: self._viewLayout)
    }
    
    #if os(iOS)
    
    public func setNeedUpdateStatusBar() {
        self.delegate?.updateStatusBar()
    }
    
    public func setNeedUpdateOrientations() {
        self.delegate?.updateOrientations()
    }
    
    #endif
    
    public func insets(of container: IQContainer) -> QInset {
        if self.container === container {
            return self.safeArea
        }
        return QInset()
    }
    
    public func didChangeInsets() {
        self.container?.didChangeInsets()
    }
    
    public func willShow(interactive: Bool) {
        self.container?.willShow(interactive: interactive)
    }
    
    public func didShow(interactive: Bool, finished: Bool) {
        self.isPresented = true
        self.container?.didShow(interactive: interactive, finished: finished)
    }

    public func willHide(interactive: Bool) {
        self.container?.willHide(interactive: interactive)
    }
    
    public func didHide(interactive: Bool, finished: Bool) {
        self.isPresented = false
        self.container?.didHide(interactive: interactive, finished: finished)
    }

}

private extension QRootContainer {
    
    class RootLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var containerItem: IQLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let containerItem = self.containerItem {
                items.append(containerItem)
            }
            return items
        }
        var size: QSize

        init() {
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                for item in self.items {
                    item.frame = bounds
                }
                size = bounds.size
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
    }
    
}
