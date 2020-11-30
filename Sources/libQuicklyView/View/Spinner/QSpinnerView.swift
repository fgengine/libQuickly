//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QSpinnerView : IQSpinnerView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var size: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var color: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColor = self.color
        }
    }
    public var isAnimating: Bool {
        set(value) {
            self._isAnimating = value
            guard self.isLoaded == true else { return }
            self._view.qIsAnimating = value
        }
        get { return self._isAnimating }
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

    private var _isAnimating: Bool
    private var _view: SpinnerView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< SpinnerView >
    
    public init(
        size: QDimensionBehaviour,
        color: QColor,
        isAnimating: Bool = false,
        alpha: QFloat = 1
    ) {
        self.size = size
        self.color = color
        self._isAnimating = isAnimating
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
        return QSize(
            width: available.width.apply(self.size),
            height: available.height.apply(self.size)
        )
    }
    
}
