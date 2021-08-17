//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import libQuicklyObserver

public struct QScrollViewDirection : OptionSet {
    
    public typealias RawValue = UInt
    
    public var rawValue: UInt
    
    @inlinable
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var horizontal = QScrollViewDirection(rawValue: 1 << 0)
    public static var vertical = QScrollViewDirection(rawValue: 1 << 1)
    
}

public enum QScrollViewScrollAlignment {
    case leading
    case center
    case trailing
}

public protocol IQScrollViewObserver : AnyObject {
    
    func beginScrolling(scrollView: IQScrollView)
    func scrolling(scrollView: IQScrollView)
    func endScrolling(scrollView: IQScrollView, decelerate: Bool)
    func beginDecelerating(scrollView: IQScrollView)
    func endDecelerating(scrollView: IQScrollView)
    
    func scrollToTop(scrollView: IQScrollView)
    
}

public protocol IQScrollView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var direction: QScrollViewDirection { set get }
    
    var indicatorDirection: QScrollViewDirection { set get }
    
    var visibleInset: QInset { set get }
    
    var contentInset: QInset { set get }
    
    var contentOffset: QPoint { set get }
    
    var contentSize: QSize { get }
    
    var isScrolling: Bool { get }
    
    var isDecelerating: Bool { get }
    
    func add(observer: IQScrollViewObserver)
    
    func remove(observer: IQScrollViewObserver)
    
    func scrollToTop(animated: Bool, completion: (() -> Void)?)

    func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint?
    
    @discardableResult
    func direction(_ value: QScrollViewDirection) -> Self
    
    @discardableResult
    func indicatorDirection(_ value: QScrollViewDirection) -> Self
    
    @discardableResult
    func visibleInset(_ value: QInset) -> Self
    
    @discardableResult
    func contentInset(_ value: QInset) -> Self
    
    @discardableResult
    func contentOffset(_ value: QPoint, normalized: Bool) -> Self
    
    @discardableResult
    func onBeginScrolling(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onScrolling(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndScrolling(_ value: ((_ decelerate: Bool) -> Void)?) -> Self
    
    @discardableResult
    func onBeginDecelerating(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndDecelerating(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onScrollToTop(_ value: (() -> Void)?) -> Self
    
}

public extension IQScrollView {
    
    var estimatedContentOffset: QPoint {
        let size = self.bounds.size
        let contentOffset = self.contentOffset
        let contentSize = self.contentSize
        let contentInset = self.contentInset
        return QPoint(
            x: (contentInset.left + contentSize.width + contentInset.right) - (contentOffset.x + size.width),
            y: (contentInset.top + contentSize.height + contentInset.bottom) - (contentOffset.y + size.height)
        )
    }
    
    @discardableResult
    func contentOffset(_ value: QPoint, normalized: Bool = false) -> Self {
        return self.contentOffset(value, normalized: normalized)
    }
    
    func scrollToTop(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.scrollToTop(animated: animated, completion: completion)
    }
    
}
