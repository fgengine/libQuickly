//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStateContainer : IQStateContainer {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            guard self.parent !== oldValue else { return }
            guard self.isPresented == true else { return }
            self.didChangeInsets()
        }
    }
    public var shouldInteractive: Bool {
        return self.container?.shouldInteractive ?? false
    }
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
    public var container: ContentContainer? {
        set(value) {
            guard self._container !== value else { return }
            if let container = self._container {
                if self.isPresented == true {
                    container.prepareHide(interactive: false)
                    container.finishHide(interactive: false)
                }
                container.parent = nil
            }
            self._container = value
            if let container = self._container {
                self._view.contentLayout.item = QLayoutItem(view: container.view)
                container.parent = self
                if self.isPresented == true {
                    container.prepareShow(interactive: false)
                    container.finishShow(interactive: false)
                }
            } else {
                self._view.contentLayout.item = nil
            }
            if self.isPresented == true {
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
            }
        }
        get { return self._container }
    }
    
    private var _view: QCustomView< Layout >
    private var _container: ContentContainer?
    
    public init(
        container: ContentContainer? = nil
    ) {
        self.isPresented = false
        self._container = container
        self._view = QCustomView(
            contentLayout: Layout(
                item: container.flatMap({ QLayoutItem(view: $0.view) })
            )
        )
        self._init()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        return self.inheritedInsets(interactive: interactive)
    }
    
    public func didChangeInsets() {
        self.container?.didChangeInsets()
    }
    
    public func activate() -> Bool {
        guard let container = self.container else { return false }
        return container.activate()
    }
    
    public func didChangeAppearance() {
        self.container?.didChangeAppearance()
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
        self.container?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.container?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.container?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.container?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.container?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.container?.cancelHide(interactive: interactive)
    }

}

extension QStateContainer : IQRootContentContainer {
}

private extension QStateContainer {
    
    func _init() {
        self.container?.parent = self
    }
    
}

private extension QStateContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var item: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        
        init(item: QLayoutItem?) {
            self.item = item
        }
        
        func layout(bounds: QRect) -> QSize {
            self.item?.frame = bounds
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
