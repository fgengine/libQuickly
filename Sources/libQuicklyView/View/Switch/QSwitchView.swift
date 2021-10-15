//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol SwitchViewDelegate : AnyObject {
    
    func changed(value: Bool)
    
}

public class QSwitchView : IQSwitchView {
        
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
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var thumbColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(thumbColor: self.thumbColor)
        }
    }
    public var offColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(offColor: self.offColor)
        }
    }
    public var onColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(onColor: self.onColor)
        }
    }
    public var value: Bool {
        set(value) {
            self._value = value
            guard self.isLoaded == true else { return }
            self._view.update(value: self._value)
        }
        get { return self._value }
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
    
    private var _reuse: QReuseItem< SwitchView >
    private var _view: SwitchView {
        return self._reuse.content()
    }
    private var _value: Bool
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onChangeValue: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    
    public init(
        reuseBehaviour: QReuseItemBehaviour = .unloadWhenDisappear,
        reuseName: String?,
        width: QDimensionBehaviour = .fill,
        height: QDimensionBehaviour,
        thumbColor: QColor,
        offColor: QColor,
        onColor: QColor,
        value: Bool,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.isVisible = false
        self.width = width
        self.height = height
        self.thumbColor = thumbColor
        self.offColor = offColor
        self.onColor = onColor
        self._value = value
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
        return available.apply(width: self.width, height: self.height)
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
    public func width(_ value: QDimensionBehaviour) -> Self {
        self.width = value
        return self
    }
    
    @discardableResult
    public func height(_ value: QDimensionBehaviour) -> Self {
        self.height = value
        return self
    }
    
    @discardableResult
    public func thumbColor(_ value: QColor) -> Self {
        self.thumbColor = value
        return self
    }
    
    @discardableResult
    public func offColor(_ value: QColor) -> Self {
        self.offColor = value
        return self
    }
    
    @discardableResult
    public func onColor(_ value: QColor) -> Self {
        self.onColor = value
        return self
    }
    
    @discardableResult
    public func value(_ value: Bool) -> Self {
        self.value = value
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
    
    @discardableResult
    public func onChangeValue(_ value: (() -> Void)?) -> Self {
        self._onChangeValue = value
        return self
    }
    
}

extension QSwitchView : SwitchViewDelegate {
    
    func changed(value: Bool) {
        self._value = value
        self._onChangeValue?()
    }
    
}
