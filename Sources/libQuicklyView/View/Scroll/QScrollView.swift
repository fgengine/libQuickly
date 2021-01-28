//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol ScrollViewDelegate : AnyObject {
    
    func update(contentSize: QSize)
    
    func beginScrolling()
    func scrolling(contentOffset: QPoint)
    func endScrolling(decelerate: Bool)
    func beginDecelerating()
    func endDecelerating()
    
}

public final class QScrollView : IQScrollView {
    
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
    public private(set) var isScrolling: Bool
    public private(set) var isDecelerating: Bool
    public private(set) var direction: QScrollViewDirection {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(direction: self.direction)
        }
    }
    public private(set) var indicatorDirection: QScrollViewDirection {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(indicatorDirection: self.indicatorDirection)
        }
    }
    public private(set) var contentInset: QInset {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(contentInset: self.contentInset)
        }
    }
    public private(set) var contentOffset: QPoint {
        set(value) {
            self._contentOffset = value
            if self.isLoaded == true {
                self._view.update(contentOffset: value, normalized: false)
            }
        }
        get { return self._contentOffset }
    }
    public private(set) var contentSize: QSize
    public private(set) var layout: IQLayout {
        willSet {
            self.layout.parentView = nil
        }
        didSet(oldValue) {
            self.layout.parentView = self
            guard self.isLoaded == true else { return }
            self._view.update(layout: self.layout)
        }
    }
    public private(set) var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public private(set) var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
            self._view.updateShadowPath()
        }
    }
    public private(set) var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public private(set) var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
            self._view.updateShadowPath()
        }
    }
    public private(set) var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuseView: QReuseView< ScrollView >
    private var _view: ScrollView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _contentOffset: QPoint
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onBeginScrolling: (() -> Void)?
    private var _onScrolling: (() -> Void)?
    private var _onEndScrolling: ((_ decelerate: Bool) -> Void)?
    private var _onBeginDecelerating: (() -> Void)?
    private var _onEndDecelerating: (() -> Void)?
    
    public init(
        direction: QScrollViewDirection = [ .vertical ],
        indicatorDirection: QScrollViewDirection = [],
        contentInset: QInset = QInset(),
        contentOffset: QPoint = QPoint(),
        layout: IQLayout,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        self.direction = direction
        self.indicatorDirection = indicatorDirection
        self.layout = layout
        self.contentInset = contentInset
        self._contentOffset = QPoint()
        self.contentSize = QSize()
        self.isScrolling = false
        self.isDecelerating = false
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuseView = QReuseView()
        self.layout.parentView = self
    }
    
    public func size(_ available: QSize) -> QSize {
        return self.layout.size(available)
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
    
    public func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint? {
        return self._view.contentOffset(with: view, horizontal: horizontal, vertical: vertical)
    }
    
    @discardableResult
    public func direction(_ value: QScrollViewDirection) -> Self {
        self.direction = value
        return self
    }
    
    @discardableResult
    public func indicatorDirection(_ value: QScrollViewDirection) -> Self {
        self.indicatorDirection = value
        return self
    }
    
    @discardableResult
    public func contentInset(_ value: QInset) -> Self {
        self.contentInset = value
        return self
    }
    
    @discardableResult
    public func contentOffset(_ value: QPoint, normalized: Bool) -> Self {
        self._contentOffset = value
        if self.isLoaded == true {
            self._view.update(contentOffset: value, normalized: normalized)
        }
        return self
    }
    
    @discardableResult
    public func layout(_ value: IQLayout) -> Self {
        self.layout = value
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
    public func onBeginScrolling(_ value: (() -> Void)?) -> Self {
        self._onBeginScrolling = value
        return self
    }
    
    @discardableResult
    public func onScrolling(_ value: (() -> Void)?) -> Self {
        self._onScrolling = value
        return self
    }
    
    @discardableResult
    public func onEndScrolling(_ value: ((_ decelerate: Bool) -> Void)?) -> Self {
        self._onEndScrolling = value
        return self
    }
    
    @discardableResult
    public func onBeginDecelerating(_ value: (() -> Void)?) -> Self {
        self._onBeginDecelerating = value
        return self
    }
    
    @discardableResult
    public func onEndDecelerating(_ value: (() -> Void)?) -> Self {
        self._onEndDecelerating = value
        return self
    }
    
}

extension QScrollView : ScrollViewDelegate {
    
    func update(contentSize: QSize) {
        self.contentSize = contentSize
    }
    
    func beginScrolling() {
        if self.isScrolling == false {
            self.isScrolling = true
            self._onBeginScrolling?()
        }
    }
    
    func scrolling(contentOffset: QPoint) {
        if self._contentOffset != contentOffset {
            self._contentOffset = contentOffset
            self._onScrolling?()
        }
    }
    
    func endScrolling(decelerate: Bool) {
        if self.isScrolling == true {
            self.isScrolling = false
            self._onEndScrolling?(decelerate)
        }
    }
    
    func beginDecelerating() {
        if self.isDecelerating == false {
            self.isDecelerating = true
            self._onBeginDecelerating?()
        }
    }
    
    func endDecelerating() {
        if self.isDecelerating == true {
            self.isDecelerating = false
            self._onEndDecelerating?()
        }
    }
    
}
