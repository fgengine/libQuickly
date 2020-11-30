//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QCustomView : IQView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var gestures: [IQGesture] {
        didSet(oldValue) {
            guard self.isLoaded == true else { return }
            self._view.qGestures = self.gestures
        }
    }
    public var layout: IQLayout {
        willSet {
            self.layout.parentView = nil
        }
        didSet(oldValue) {
            self.layout.parentView = self
            guard self.isLoaded == true else { return }
            self._view.qLayout = self.layout
        }
    }
    public var isOpaque: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qIsOpaque = self.isOpaque
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.qIsAppeared
    }
    public var native: QNativeView {
        return self._view
    }

    private var _view: LayoutView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< LayoutView >
    
    public init(
        gestures: [IQGesture] = [],
        layout: IQLayout,
        isOpaque: Bool = true,
        alpha: QFloat = 1
    ) {
        self.gestures = gestures
        self.layout = layout
        self.isOpaque = isOpaque
        self.alpha = alpha
        self._reuseView = QReuseView()
        self.layout.parentView = self
    }
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return self.layout.size(available)
    }

}
