//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QRateView : IQRateView {
    
    public private(set) unowned var layout: IQLayout?
    public unowned var item: QLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuse.isLoaded
    }
    public var bounds: QRect {
        guard self.isLoaded == true else { return .zero }
        return QRect(self._view.bounds)
    }
    public private(set) var isVisible: Bool
    public var isHidden: Bool {
        didSet(oldValue) {
            guard self.isHidden != oldValue else { return }
            self.setNeedForceLayout()
        }
    }
    public var itemSize: QSize {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(itemSize: self.itemSize)
            self.setNeedForceLayout()
        }
    }
    public var itemSpacing: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(itemSpacing: self.itemSpacing)
            self.setNeedForceLayout()
        }
    }
    public var numberOfItem: UInt {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(numberOfItem: self.numberOfItem)
            self.setNeedForceLayout()
        }
    }
    public var rounding: QRateViewRounding {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(rounding: self.rounding)
        }
    }
    public var states: [QRateViewState] {
        set(value) {
            guard self.isLoaded == true else { return }
            self._states = Self._sort(states: value)
            self._view.update(states: self._states)
        }
        get { return self._states }
    }
    public var rating: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(rating: self.rating)
        }
    }
    public var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
        }
    }
    public var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
        }
    }
    public var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< Reusable >
    private var _view: NativeRateView {
        return self._reuse.content()
    }
    private var _states: [QRateViewState]
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    
    public init(
        reuseBehaviour: QReuseItemBehaviour = .unloadWhenDisappear,
        reuseName: String? = nil,
        itemSize: QSize,
        itemSpacing: Float,
        numberOfItem: UInt,
        rounding: QRateViewRounding = .down,
        states: [QRateViewState],
        rating: Float,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.isVisible = false
        self.itemSize = itemSize
        self.itemSpacing = itemSpacing
        self.numberOfItem = numberOfItem
        self.rounding = rounding
        self._states = Self._sort(states: states)
        self.rating = rating
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self.isHidden = isHidden
        self._reuse = QReuseItem(behaviour: reuseBehaviour, name: reuseName)
        self._reuse.configure(owner: self)
    }
    
    deinit {
        self._reuse.destroy()
    }
    
    public func loadIfNeeded() {
        self._reuse.loadIfNeeded()
    }
    
    public func size(available: QSize) -> QSize {
        guard self.isHidden == false else { return .zero }
        if self.numberOfItem > 1 {
            return QSize(
                width: (self.itemSize.width * Float(self.numberOfItem)) + (self.itemSpacing * Float(self.numberOfItem - 1)),
                height: self.itemSize.height
            )
        } else if self.numberOfItem > 0 {
            return self.itemSize
        }
        return .zero
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.disappear()
        self.layout = nil
        self._onDisappear?()
    }
    
    public func visible() {
        self.isVisible = true
        self._onVisible?()
    }
    
    public func visibility() {
        self._onVisibility?()
    }
    
    public func invisible() {
        self.isVisible = false
        self._onInvisible?()
    }
    
    @discardableResult
    public func itemSize(_ value: QSize) -> Self {
        self.itemSize = value
        return self
    }
    
    @discardableResult
    public func itemSpacing(_ value: Float) -> Self {
        self.itemSpacing = value
        return self
    }
    
    @discardableResult
    public func numberOfItem(_ value: UInt) -> Self {
        self.numberOfItem = value
        return self
    }
    
    @discardableResult
    public func rounding(_ value: QRateViewRounding) -> Self {
        self.rounding = value
        return self
    }
    
    @discardableResult
    public func states(_ value: [QRateViewState]) -> Self {
        self.states = value
        return self
    }
    
    @discardableResult
    public func rating(_ value: Float) -> Self {
        self.rating = value
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
    
    @discardableResult
    public func hidden(_ value: Bool) -> Self {
        self.isHidden = value
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._onAppear = value
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._onDisappear = value
        return self
    }
    
    @discardableResult
    public func onVisible(_ value: (() -> Void)?) -> Self {
        self._onVisible = value
        return self
    }
    
    @discardableResult
    public func onVisibility(_ value: (() -> Void)?) -> Self {
        self._onVisibility = value
        return self
    }
    
    @discardableResult
    public func onInvisible(_ value: (() -> Void)?) -> Self {
        self._onInvisible = value
        return self
    }
    
}

private extension QRateView {
    
    static func _sort(states: [QRateViewState]) -> [QRateViewState] {
        return states.sorted(by: { $0.rate < $1.rate })
    }
    
}
