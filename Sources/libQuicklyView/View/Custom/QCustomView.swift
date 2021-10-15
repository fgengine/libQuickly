//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol NativeCustomViewDelegate : AnyObject {
    
    func shouldHighlighting(view: NativeCustomView) -> Bool
    func set(view: NativeCustomView, highlighted: Bool)
    
}

public class QCustomView< Layout : IQLayout > : IQCustomView {
    
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
    public var gestures: [IQGesture] {
        set(value) {
            self._gestures = value
            if self.isLoaded == true {
                self._view.update(gestures: value)
            }
        }
        get { return self._gestures }
    }
    public var contentLayout: Layout {
        willSet {
            self.contentLayout.view = nil
        }
        didSet(oldValue) {
            self.contentLayout.view = self
            guard self.isLoaded == true else { return }
            self._view.update(contentLayout: self.contentLayout)
            self.contentLayout.setNeedForceUpdate()
            self.setNeedForceLayout()
        }
    }
    public var contentSize: QSize {
        get {
            guard self.isLoaded == true else { return .zero }
            return self._view.contentSize
        }
    }
    public var shouldHighlighting: Bool {
        didSet {
            if self.shouldHighlighting == false {
                self.isHighlighted = false
            }
        }
    }
    public var isHighlighted: Bool {
        set(value) {
            if self._isHighlighted != value {
                self._isHighlighted = value
                self.triggeredChangeStyle(false)
            }
        }
        get { return self._isHighlighted }
    }
    public var isLocked: Bool {
        set(value) {
            if self._isLocked != value {
                self._isLocked = value
                self.triggeredChangeStyle(false)
            }
        }
        get { return self._isLocked }
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
            self._view.updateShadowPath()
        }
    }
    public var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
            self._view.updateShadowPath()
        }
    }
    public var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< Reusable >
    private var _view: Reusable.Content {
        return self._reuse.content()
    }
    private var _gestures: [IQGesture]
    private var _isHighlighted: Bool
    private var _isLocked: Bool
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    private var _onChangeStyle: ((_ userIteraction: Bool) -> Void)?
    
    public init(
        gestures: [IQGesture] = [],
        contentLayout: Layout,
        shouldHighlighting: Bool = false,
        isHighlighted: Bool = false,
        isLocked: Bool = false,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.isVisible = false
        self._gestures = gestures
        self.contentLayout = contentLayout
        self.shouldHighlighting = shouldHighlighting
        self._isHighlighted = shouldHighlighting == true && isHighlighted == true
        self._isLocked = isLocked
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self.isHidden = isHidden
        self._reuse = QReuseItem()
        self.contentLayout.view = self
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
        return self.contentLayout.size(available: available)
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
    
    public func triggeredChangeStyle(_ userIteraction: Bool) {
        self._onChangeStyle?(userIteraction)
    }
    
    @discardableResult
    public func gestures(_ value: [IQGesture]) -> Self {
        self.gestures = value
        return self
    }
    
    @discardableResult
    public func add(gesture: IQGesture) -> Self {
        if self._gestures.contains(where: { $0 === gesture }) == false {
            self._gestures.append(gesture)
            if self.isLoaded == true {
                self._view.add(gesture: gesture)
            }
        }
        return self
    }
    
    @discardableResult
    public func remove(gesture: IQGesture) -> Self {
        if let index = self._gestures.firstIndex(where: { $0 === gesture }) {
            self._gestures.remove(at: index)
            if self.isLoaded == true {
                self._view.remove(gesture: gesture)
            }
        }
        return self
    }
    
    @discardableResult
    public func contentLayout(_ value: Layout) -> Self {
        self.contentLayout = value
        return self
    }
    
    @discardableResult
    public func shouldHighlighting(_ value: Bool) -> Self {
        self.shouldHighlighting = value
        return self
    }
    
    @discardableResult
    public func highlight(_ value: Bool) -> Self {
        self.isHighlighted = value
        return self
    }
    
    @discardableResult
    public func lock(_ value: Bool) -> Self {
        self.isLocked = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self.color = value
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self.cornerRadius = value
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self.border = value
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
    public func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self {
        self._onChangeStyle = value
        return self
    }

}

extension QCustomView : NativeCustomViewDelegate {
    
    func shouldHighlighting(view: NativeCustomView) -> Bool {
        return self.shouldHighlighting
    }
    
    func set(view: NativeCustomView, highlighted: Bool) {
        if self._isHighlighted != highlighted {
            self._isHighlighted = highlighted
            self._onChangeStyle?(true)
        }
    }
    
}
