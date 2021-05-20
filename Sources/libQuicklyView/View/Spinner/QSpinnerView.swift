//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QSpinnerView : IQSpinnerView {
    
    public private(set) unowned var layout: IQLayout?
    public unowned var item: QLayoutItem?
    public private(set) var name: String
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuse.isLoaded
    }
    public var bounds: QRect {
        guard self.isLoaded == true else { return QRect() }
        return QRect(self._view.bounds)
    }
    public private(set) var size: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
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
    public private(set) var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< SpinnerView >
    private var _view: SpinnerView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _isAnimating: Bool
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        name: String? = nil,
        size: QDimensionBehaviour,
        activityColor: QColor,
        isAnimating: Bool = false,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.name = name ?? String(describing: Self.self)
        self.size = size
        self.activityColor = activityColor
        self._isAnimating = isAnimating
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem()
    }
    
    public func size(_ available: QSize) -> QSize {
        return QSize(
            width: available.width.apply(self.size),
            height: available.height.apply(self.size)
        )
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.unload(owner: self)
        self.layout = nil
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
    public func alpha(_ value: Float) -> Self {
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
