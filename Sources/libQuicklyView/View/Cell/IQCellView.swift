//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCellView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var shouldHighlighting: Bool { get }
    var isHighlighted: Bool { get }
    var shouldPressed: Bool { get }
    var contentView: IQView { get }
    var leadingView: IQView? { get }
    var leadingSize: QFloat { get }
    var leadingLimit: QFloat { get }
    var trailingView: IQView? { get }
    var trailingSize: QFloat { get }
    var trailingLimit: QFloat { get }
    #if os(iOS)
    var interactiveLimit: QFloat { get }
    var interactiveVelocity: QFloat { get }
    #endif
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func isHighlighted(_ value: Bool) -> Self
    
    @discardableResult
    func shouldPressed(_ value: Bool) -> Self
    
    @discardableResult
    func contentView(_ value: IQView) -> Self
    
    @discardableResult
    func leadingView(_ value: IQView?) -> Self
    
    @discardableResult
    func leadingSize(_ value: QFloat) -> Self
    
    @discardableResult
    func leadingLimit(_ value: QFloat) -> Self
    
    @discardableResult
    func trailingView(_ value: IQView?) -> Self
    
    @discardableResult
    func trailingSize(_ value: QFloat) -> Self
    
    @discardableResult
    func trailingLimit(_ value: QFloat) -> Self
    
    #if os(iOS)
    
    @discardableResult
    func interactiveLimit(_ value: QFloat) -> Self
    
    @discardableResult
    func interactiveVelocity(_ value: QFloat) -> Self
    
    #endif

    @discardableResult
    func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self
    
    @discardableResult
    func onShowLeading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onHideLeading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onShowTrailing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onHideTrailing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onPressed(_ value: (() -> Void)?) -> Self
    
}
