//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import libQuicklyObserver

protocol ScrollViewDelegate : AnyObject {
    
    func _update(contentSize: QSize)
    
    func _beginScrolling()
    func _scrolling(contentOffset: QPoint)
    func _endScrolling(decelerate: Bool)
    func _beginDecelerating()
    func _endDecelerating()
    
    func _scrollToTop()
    
}

public class QScrollView : IQScrollView {
    
    public private(set) unowned var layout: IQLayout?
    public unowned var item: QLayoutItem?
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
    public private(set) var contentLayout: IQLayout {
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
    public private(set) var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< ScrollView >
    private var _view: ScrollView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _contentOffset: QPoint
    private var _observer: QObserver< IQScrollViewObserver >
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onBeginScrolling: (() -> Void)?
    private var _onScrolling: (() -> Void)?
    private var _onEndScrolling: ((_ decelerate: Bool) -> Void)?
    private var _onBeginDecelerating: (() -> Void)?
    private var _onEndDecelerating: (() -> Void)?
    private var _onScrollToTop: (() -> Void)?
    
    public init(
        direction: QScrollViewDirection = [ .vertical ],
        indicatorDirection: QScrollViewDirection = [],
        contentInset: QInset = QInset(),
        contentOffset: QPoint = QPoint(),
        contentLayout: IQLayout,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.direction = direction
        self.indicatorDirection = indicatorDirection
        self.contentInset = contentInset
        self.contentLayout = contentLayout
        self.contentSize = QSize()
        self.isScrolling = false
        self.isDecelerating = false
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem()
        self._observer = QObserver()
        self._contentOffset = QPoint()
        self.contentLayout.view = self
    }
    
    public func size(_ available: QSize) -> QSize {
        return self.contentLayout.size(available)
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
    
    public func add(observer: IQScrollViewObserver) {
        self._observer.add(observer, priority: 0)
    }
    
    public func remove(observer: IQScrollViewObserver) {
        self._observer.remove(observer)
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
    public func contentLayout(_ value: IQLayout) -> Self {
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
        self._view.update(contentOffset: beginContentOffset, normalized: false)
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
            self.contentOffset(QPoint(x: -contentInset.left, y: -contentInset.top))
            self._scrollToTop()
            completion?()
        }
    }
    
}

extension QScrollView : ScrollViewDelegate {
    
    func _update(contentSize: QSize) {
        self.contentSize = contentSize
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
