//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QSpinnerView : IQSpinnerView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.isAppeared
    }
    public private(set) var size: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var activityColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(activityColor: self.activityColor)
        }
    }
    public private(set) var isAnimating: Bool {
        set(value) {
            self._isAnimating = value
            guard self.isLoaded == true else { return }
            self._view.update(isAnimating: value)
        }
        get { return self._isAnimating }
    }
    public private(set) var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public private(set) var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public private(set) var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
        }
    }
    public private(set) var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
        }
    }
    public private(set) var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuseView: QReuseView< SpinnerView >
    private var _view: SpinnerView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _isAnimating: Bool
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        size: QDimensionBehaviour,
        activityColor: QColor,
        isAnimating: Bool = false,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        self.size = size
        self.activityColor = activityColor
        self._isAnimating = isAnimating
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuseView = QReuseView()
    }
    
    public func size(_ available: QSize) -> QSize {
        return QSize(
            width: available.width.apply(self.size),
            height: available.height.apply(self.size)
        )
    }
    
    public func appear(to layout: IQLayout) {
        self.parentLayout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
        self._onDisappear?()
    }
    
    @discardableResult
    public func size(_ value: QDimensionBehaviour) -> Self {
        self.size = value
        return self
    }
    
    @discardableResult
    public func activityColor(_ value: QColor) -> Self {
        self.activityColor = value
        return self
    }
    
    @discardableResult
    public func animating(_ value: Bool) -> Self {
        self.isAnimating = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self.color = value
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self.border = value
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self.cornerRadius = value
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self.shadow = value
        return self
    }
    
    @discardableResult
    public func alpha(_ value: QFloat) -> Self {
        self.alpha = value
        return self
    }
    
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._onAppear = value
        return self
    }
    
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._onDisappear = value
        return self
    }
    
}
