//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QScrollView : IQView {
    
    public typealias SimpleClosure = (_ scrollView: QScrollView) -> Void
    public typealias EndScrollingClosure = (_ scrollView: QScrollView, _ decelerating: Bool) -> Void
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var direction: Direction {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qDirection = self.direction
        }
    }
    public var layout: IQLayout {
        willSet {
            self.layout.parentView = nil
        }
        didSet(oldValue) {
            self.layout.parentView = self
            guard self.isLoaded == true else { return }
            self._view.qLayout = self.layout
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var onBeginScrolling: SimpleClosure?
    public var onScrolling: SimpleClosure?
    public var onEndScrolling: EndScrollingClosure?
    public var onBeginDecelerating: SimpleClosure?
    public var onEndDecelerating: SimpleClosure?
    public var contentInset: QInset {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qContentInset = self.contentInset
        }
    }
    public private(set) var contentOffset: QPoint
    public private(set) var contentSize: QSize
    public private(set) var isScrolling: Bool
    public private(set) var isDecelerating: Bool
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

    private var _view: ScrollView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< ScrollView >
    
    public init(
        direction: Direction = [ .vertical ],
        layout: IQLayout,
        alpha: QFloat = 1,
        contentInset: QInset = QInset(),
        onBeginScrolling: SimpleClosure? = nil,
        onScrolling: SimpleClosure? = nil,
        onEndScrolling: EndScrollingClosure? = nil,
        onBeginDecelerating: SimpleClosure? = nil,
        onEndDecelerating: SimpleClosure? = nil
    ) {
        self.direction = direction
        self.layout = layout
        self.alpha = alpha
        self.onBeginScrolling = onBeginScrolling
        self.onScrolling = onScrolling
        self.onEndScrolling = onEndScrolling
        self.onBeginDecelerating = onBeginDecelerating
        self.onEndDecelerating = onEndDecelerating
        self.contentInset = contentInset
        self.contentOffset = QPoint()
        self.contentSize = QSize()
        self.isScrolling = false
        self.isDecelerating = false
        self._reuseView = QReuseView()
        self.layout.parentView = self
    }
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return self.layout.size(available)
    }
    
    public func scroll(to point: QPoint) {
        guard self.isLoaded == true else { return }
        self._view.contentOffset = point.cgPoint
    }
    
}

public extension QScrollView {
    
    struct Direction : OptionSet {
        
        public typealias RawValue = UInt
        
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static var horizontal = Direction(rawValue: 0x01)
        public static var vertical = Direction(rawValue: 0x02)
        
    }
    
}

protocol ScrollViewDelegate : AnyObject {
    
    func update(contentSize: QSize)
    
    func beginScrolling()
    func scrolling(contentOffset: QPoint)
    func endScrolling(decelerating: Bool)
    func beginDecelerating()
    func endDecelerating()
    
}

extension QScrollView : ScrollViewDelegate {
    
    func update(contentSize: QSize) {
        self.contentSize = contentSize
    }
    
    func beginScrolling() {
        if self.isScrolling == false {
            self.isScrolling = true
            self.onBeginScrolling?(self)
        }
    }
    
    func scrolling(contentOffset: QPoint) {
        if self.contentOffset != contentOffset {
            self.contentOffset = contentOffset
            self.onScrolling?(self)
        }
    }
    
    func endScrolling(decelerating: Bool) {
        if self.isScrolling == true {
            self.isScrolling = false
            self.onEndScrolling?(self, decelerating)
        }
    }
    
    func beginDecelerating() {
        if self.isDecelerating == false {
            self.isDecelerating = true
            self.onBeginDecelerating?(self)
        }
    }
    
    func endDecelerating() {
        if self.isDecelerating == true {
            self.isDecelerating = false
            self.onEndDecelerating?(self)
        }
    }
    
}
