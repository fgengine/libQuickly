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
        return self._container?.statusBarHidden ?? false
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self._container?.statusBarStyle ?? .default
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self._container?.statusBarAnimation ?? .fade
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self._container?.supportedOrientations ?? .all
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
        set(value) {
            guard self._container !== value else { return }
            if let container = self._container {
                if self.isPresented == true {
                    container.prepareHide(interactive: false)
                    container.finishHide(interactive: false)
                }
                container.rootContainer = nil
            }
            self._container = value
            if let container = self._container {
                self._viewLayout.containerItem = QLayoutItem(view: container.view)
                container.rootContainer = self
                if self.isPresented == true {
                    container.prepareShow(interactive: false)
                    container.finishShow(interactive: false)
                }
            } else {
                self._viewLayout.containerItem = nil
            }
        }
        get { return self._container }
    }
    
    private var _view: QCustomView
    private var _viewLayout: RootLayout
    private var _container: IQRootContentContainer?
    
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
        if self._container === container {
            return self.safeArea
        }
        return QInset()
    }
    
    public func didChangeInsets() {
        self._container?.didChangeInsets()
    }
    
    public func prepareShow(interactive: Bool) {
        self._container?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self._container?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self._container?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self._container?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self._container?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self._container?.cancelHide(interactive: interactive)
    }

}

private extension QRootContainer {
    
    class RootLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var containerItem: IQLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        
        func layout(bounds: QRect) -> QSize {
            self.containerItem?.frame = bounds
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let containerItem = self.containerItem {
                items.append(containerItem)
            }
            return items
        }
        
    }
    
}
