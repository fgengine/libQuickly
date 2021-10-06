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
    public var statusBarView: IQStatusBarView? {
        didSet(oldValue) {
            guard self.statusBarView !== oldValue else { return }
            self._view.contentLayout.statusBarItem = self.statusBarView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var safeArea: QInset {
        didSet(oldValue) {
            guard self.safeArea != oldValue else { return }
            self.didChangeInsets()
        }
    }
    public var overlayContainer: IQRootContentContainer? {
        didSet(oldValue) {
            guard self.overlayContainer !== oldValue else { return }
            if let overlayContainer = self.overlayContainer {
                if self.isPresented == true {
                    overlayContainer.prepareHide(interactive: false)
                    overlayContainer.finishHide(interactive: false)
                }
                overlayContainer.parent = nil
            }
            self._view.contentLayout.overlayItem = self.overlayContainer.flatMap({ QLayoutItem(view: $0.view) })
            if let overlayContainer = self.overlayContainer {
                overlayContainer.parent = self
                if self.isPresented == true {
                    overlayContainer.prepareShow(interactive: false)
                    overlayContainer.finishShow(interactive: false)
                }
            }
        }
    }
    public var contentContainer: IQRootContentContainer {
        didSet(oldValue) {
            guard self.contentContainer !== oldValue else { return }
            if self.isPresented == true {
                self.contentContainer.prepareHide(interactive: false)
                self.contentContainer.finishHide(interactive: false)
            }
            self.contentContainer.parent = nil
            self._view.contentLayout.contentItem = QLayoutItem(view: self.contentContainer.view)
            self.contentContainer.parent = self
            if self.isPresented == true {
                self.contentContainer.prepareShow(interactive: false)
                self.contentContainer.finishShow(interactive: false)
            }
        }
    }
    
    private var _view: QCustomView< Layout >
    
    public init(
        statusBarView: IQStatusBarView? = nil,
        overlayContainer: IQRootContentContainer?,
        contentContainer: IQRootContentContainer
    ) {
        self.isPresented = false
        self.statusBarView = statusBarView
        self.overlayContainer = overlayContainer
        self.contentContainer = contentContainer
        self.safeArea = .zero
        self._view = QCustomView(
            contentLayout: Layout(
                statusBarItem: statusBarView.flatMap({ QLayoutItem(view: $0) }),
                overlayItem: self.overlayContainer.flatMap({ QLayoutItem(view: $0.view) }),
                contentItem: QLayoutItem(view: contentContainer.view)
            )
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
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        if self.overlayContainer === container {
            return self.safeArea
        } else if self.contentContainer === container {
            return self.safeArea
        }
        return .zero
    }
    
    public func didChangeInsets() {
        self.overlayContainer?.didChangeInsets()
        self.contentContainer.didChangeInsets()
    }
    
    public func activate() -> Bool {
        if let overlayContainer = self.overlayContainer {
            if overlayContainer.activate() == true {
                return true
            }
        }
        return self.contentContainer.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
        self.overlayContainer?.prepareShow(interactive: interactive)
        self.contentContainer.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.overlayContainer?.finishShow(interactive: interactive)
        self.contentContainer.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.overlayContainer?.cancelShow(interactive: interactive)
        self.contentContainer.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.overlayContainer?.prepareHide(interactive: interactive)
        self.contentContainer.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.overlayContainer?.finishHide(interactive: interactive)
        self.contentContainer.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.overlayContainer?.cancelHide(interactive: interactive)
        self.contentContainer.cancelHide(interactive: interactive)
    }

}

private extension QRootContainer {
    
    func _init() {
        self.overlayContainer?.parent = self
        self.contentContainer.parent = self
    }
    
}

private extension QRootContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var statusBarItem: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var overlayItem: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        
        init(
            statusBarItem: QLayoutItem?,
            overlayItem: QLayoutItem?,
            contentItem: QLayoutItem
        ) {
            self.statusBarItem = statusBarItem
            self.overlayItem = overlayItem
            self.contentItem = contentItem
        }
        
        func layout(bounds: QRect) -> QSize {
            if let overlayItem = self.overlayItem {
                overlayItem.frame = bounds
            }
            if let statusBarItem = self.statusBarItem {
                let statusBarSize = statusBarItem.size(available: QSize(width: bounds.size.width, height: .infinity))
                statusBarItem.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: statusBarSize.width,
                    height: statusBarSize.height
                )
            }
            self.contentItem.frame = bounds
            return bounds.size
        }
        
        func size(available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items = [
                self.contentItem
            ]
            if let statusBarItem = self.statusBarItem {
                items.append(statusBarItem)
            }
            if let overlayItem = self.overlayItem {
                items.append(overlayItem)
            }
            return items
        }
        
    }
    
}
