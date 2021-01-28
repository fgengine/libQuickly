//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QScrollViewDirection : OptionSet {
    
    public typealias RawValue = UInt
    
    public var rawValue: UInt
    
    @inlinable
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var horizontal = QScrollViewDirection(rawValue: 0x01)
    public static var vertical = QScrollViewDirection(rawValue: 0x02)
    
}

public enum QScrollViewScrollAlignment {
    case leading
    case center
    case trailing
}

public protocol IQScrollView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var isScrolling: Bool { get }
    var isDecelerating: Bool { get }
    var direction: QScrollViewDirection { get }
    var indicatorDirection: QScrollViewDirection { get }
    var contentInset: QInset { get }
    var contentOffset: QPoint { get }
    var contentSize: QSize { get }
    var layout: IQLayout { get }

    func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint?
    
    @discardableResult
    func direction(_ value: QScrollViewDirection) -> Self
    
    @discardableResult
    func indicatorDirection(_ value: QScrollViewDirection) -> Self
    
    @discardableResult
    func contentInset(_ value: QInset) -> Self
    
    @discardableResult
    func contentOffset(_ value: QPoint, normalized: Bool) -> Self
    
    @discardableResult
    func layout(_ value: IQLayout) -> Self
    
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
    
}

public extension IQScrollView {
    
    @discardableResult
    func contentOffset(_ value: QPoint, normalized: Bool = false) -> Self {
        return self.contentOffset(value, normalized: normalized)
    }
    
}
