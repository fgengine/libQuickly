//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import libQuicklyObserver

protocol ScrollViewDelegate : AnyObject {
    
    func _update(contentSize: QSize)
    
    func _triggeredRefresh()

    func _beginScrolling()
    func _scrolling(contentOffset: QPoint)
    func _endScrolling(decelerate: Bool)
    func _beginDecelerating()
    func _endDecelerating()
    
    func _scrollToTop()
    
}

public class QScrollView< Layout : IQLayout > : IQScrollView {
    
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
    public var direction: QScrollViewDirection {
        didSet(oldValue) {
            guard self.direction != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(direction: self.direction)
        }
    }
    public var indicatorDirection: QScrollViewDirection {
        didSet(oldValue) {
            guard self.indicatorDirection != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(indicatorDirection: self.indicatorDirection)
        }
    }
    public var contentInset: QInset {
        didSet(oldValue) {
            guard self.contentInset != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(contentInset: self.contentInset)
        }
    }
    public var contentOffset: QPoint {
        set(value) {
            self._contentOffset = value
            if self.isLoaded == true {
                self._view.update(contentOffset: value, normalized: false)
            }
        }
        get { return self._contentOffset }
    }
    public var visibleInset: QInset {
        didSet(oldValue) {
            guard self.visibleInset != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(visibleInset: self.visibleInset)
        }
    }
    public private(set) var contentSize: QSize
    public var contentLayout: Layout {
        willSet {
            self.contentLayout.view = nil
        }
        didSet(oldValue) {
            self.contentLayout.view = self
            guard self.isLoaded == true else { return }
            self._view.update(contentLayout: self.contentLayout)
        }
    }
    public private(set) var isScrolling: Bool
    public private(set) var isDecelerating: Bool
    @available(iOS 10.0, *)
    public var refreshColor: QColor? {
        set(value) {
            guard self._refreshColor != value else { return }
            self._refreshColor = value
            guard self.isLoaded == true else { return }
            self._view.update(refreshColor: self._refreshColor)
        }
        get { return self._refreshColor }
    }
    @available(iOS 10.0, *)
    public var isRefreshing: Bool {
        set(value) {
            guard self._isRefreshing != value else { return }
            self._isRefreshing = value
            guard self.isLoaded == true else { return }
            self._view.update(isRefreshing: self._isRefreshing)
        }
        get { return self._isRefreshing }
    }
    public var color: QColor? {
        didSet(oldValue) {
            guard self.color != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var cornerRadius: QViewCornerRadius {
        didSet(oldValue) {
            guard self.cornerRadius != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
            self._view.updateShadowPath()
        }
    }
    public var border: QViewBorder {
        didSet(oldValue) {
            guard self.border != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public var shadow: QViewShadow? {
        didSet(oldValue) {
            guard self.shadow != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
            self._view.updateShadowPath()
        }
    }
    public var alpha: Float {
        didSet(oldValue) {
            guard self.alpha != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< Reusable >
    private var _view: Reusable.Content {
        return self._reuse.content()
    }
    private var _contentOffset: QPoint
    private var _refreshColor: QColor?
    private var _isRefreshing: Bool
    private var _observer: QObserver< IQScrollViewObserver >
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    private var _onTriggeredRefresh: (() -> Void)?
    private var _onBeginScrolling: (() -> Void)?
    private var _onScrolling: (() -> Void)?
    private var _onEndScrolling: ((_ decelerate: Bool) -> Void)?
    private var _onBeginDecelerating: (() -> Void)?
    private var _onEndDecelerating: (() -> Void)?
    private var _onScrollToTop: (() -> Void)?
    
    public init(
        direction: QScrollViewDirection = [ .vertical ],
        indicatorDirection: QScrollViewDirection = [],
        visibleInset: QInset = .zero,
        contentInset: QInset = .zero,
        contentOffset: QPoint = .zero,
        contentLayout: Layout,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.isVisible = false
        self.direction = direction
        self.indicatorDirection = indicatorDirection
        self.visibleInset = visibleInset
        self.contentInset = contentInset
        self.contentLayout = contentLayout
        self.contentSize = .zero
        self.isScrolling = false
        self.isDecelerating = false
        self._isRefreshing = false
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem()
        self._observer = QObserver()
        self._contentOffset = contentOffset
        self.contentLayout.view = self
        self._reuse.configure(owner: self)
    }
    
    deinit {
        self._reuse.destroy()
    }
    
    public func loadIfNeeded() {
        self._reuse.loadIfNeeded()
    }
    
    public func size(_ available: QSize) -> QSize {
        return available
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
    
    public func add(observer: IQScrollViewObserver) {
        self._observer.add(observer, priority: 0)
    }
    
    public func remove(observer: IQScrollViewObserver) {
        self._observer.remove(observer)
    }
    
    public func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint? {
        return self._view.contentOffset(with: view, horizontal: horizontal, vertical: vertical)
    }
    
    @available(iOS 10.0, *)
    @discardableResult
    public func beginRefresh() -> Self {
        self.isRefreshing = true
        return self
    }
    
    @available(iOS 10.0, *)
    @discardableResult
    public func endRefresh() -> Self {
        self.isRefreshing = false
        return self
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
    public func visibleInset(_ value: QInset) -> Self {
        self.visibleInset = value
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
    
    @available(iOS 10.0, *)
    @discardableResult
    public func refreshColor(_ value: QColor?) -> Self {
        self.refreshColor = value
        return self
    }
    
    @discardableResult
    public func contentLayout(_ value: Layout) -> Self {
        self.contentLayout = value
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
    
    @available(iOS 10.0, *)
    @discardableResult
    public func onTriggeredRefresh(_ value: (() -> Void)?) -> Self {
        self._onTriggeredRefresh = value
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
    
    @discardableResult
    public func onScrollToTop(_ value: (() -> Void)?) -> Self {
        self._onScrollToTop = value
        return self
    }
    
    public func scrollToTop(animated: Bool, completion: (() -> Void)?) {
        let contentInset = self.contentInset
        let beginContentOffset = self.contentOffset
        let endContentOffset = QPoint(x: -contentInset.left, y: -contentInset.top)
        let deltaContentOffset = abs(beginContentOffset.distance(to: endContentOffset))
        if animated == true && deltaContentOffset > 0 {
            let velocity = max(self.bounds.width, self.bounds.height) * 5
            QAnimation.default.run(
                duration: TimeInterval(deltaContentOffset / velocity),
                ease: QAnimation.Ease.QuadraticInOut(),
                processing: { [unowned self] progress in
                    let contentOffset = beginContentOffset.lerp(endContentOffset, progress: progress)
                    self.contentOffset(contentOffset)
                },
                completion: { [unowned self] in
                    self._scrollToTop()
                    completion?()
                }
            )
        } else {
            self.contentOffset = QPoint(x: -contentInset.left, y: -contentInset.top)
            self._scrollToTop()
            completion?()
        }
    }
    
}

extension QScrollView : ScrollViewDelegate {
    
    func _update(contentSize: QSize) {
        self.contentSize = contentSize
    }
    
    func _triggeredRefresh() {
        self._onTriggeredRefresh?()
    }
    
    func _beginScrolling() {
        if self.isScrolling == false {
            self.isScrolling = true
            self._onBeginScrolling?()
            self._observer.notify({ $0.beginScrolling(scrollView: self) })
        }
    }
    
    func _scrolling(contentOffset: QPoint) {
        if self._contentOffset != contentOffset {
            self._contentOffset = contentOffset
            self._onScrolling?()
            self._observer.notify({ $0.scrolling(scrollView: self) })
        }
    }
    
    func _endScrolling(decelerate: Bool) {
        if self.isScrolling == true {
            self.isScrolling = false
            self._onEndScrolling?(decelerate)
            self._observer.notify({ $0.endScrolling(scrollView: self, decelerate: decelerate) })
        }
    }
    
    func _beginDecelerating() {
        if self.isDecelerating == false {
            self.isDecelerating = true
            self._onBeginDecelerating?()
            self._observer.notify({ $0.beginDecelerating(scrollView: self) })
        }
    }
    
    func _endDecelerating() {
        if self.isDecelerating == true {
            self.isDecelerating = false
            self._onEndDecelerating?()
            self._observer.notify({ $0.endDecelerating(scrollView: self) })
        }
    }
    
    func _scrollToTop() {
        self._onScrollToTop?()
        self._observer.notify({ $0.scrollToTop(scrollView: self) })
    }
    
}
