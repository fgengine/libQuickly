//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QRootContainer : IQRootContainer {
    
    public unowned var delegate: IQRootContainerDelegate?
    public var shouldInteractive: Bool {
        return self.container.shouldInteractive
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self.container.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self.container.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self.container.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self.container.supportedOrientations
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
    public var container: IQRootContentContainer {
        didSet(oldValue) {
            guard self.container !== oldValue else { return }
            if self.isPresented == true {
                self.container.prepareHide(interactive: false)
                self.container.finishHide(interactive: false)
            }
            self.container.parent = nil
            self._layout.item = QLayoutItem(view: self.container.view)
            self.container.parent = self
            if self.isPresented == true {
                self.container.prepareShow(interactive: false)
                self.container.finishShow(interactive: false)
            }
        }
    }
    
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    
    public init(
        safeArea: QInset = QInset(),
        container: IQRootContentContainer
    ) {
        self.isPresented = false
        self.safeArea = safeArea
        self.container = container
        self._layout = Layout(
            item: QLayoutItem(view: container.view)
        )
        self._view = QCustomView(
            contentLayout: self._layout
        )
        self._init()
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
        self.container.didChangeInsets()
    }
    
    public func activate() -> Bool {
        return self.container.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.container.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.container.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.container.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.container.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.container.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.container.cancelHide(interactive: interactive)
    }

}

private extension QRootContainer {
    
    func _init() {
        self.container.parent = self
    }
    
}

private extension QRootContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var item: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        
        init(item: QLayoutItem) {
            self.item = item
        }
        
        func invalidate(item: QLayoutItem) {
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            self.item.frame = bounds
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            return [ self.item ]
        }
        
    }
    
}
