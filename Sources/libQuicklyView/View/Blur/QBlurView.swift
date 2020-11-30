//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

open class QBlurView : IQView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var style: UIBlurEffect.Style {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qStyle = self.style
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
    
    private var _view: BlurView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< BlurView >
    
    public init(
        style: UIBlurEffect.Style,
        alpha: QFloat = 1
    ) {
        self.style = style
        self.alpha = alpha
        self._reuseView = QReuseView()
    }

    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return available
    }
    
}

#endif
