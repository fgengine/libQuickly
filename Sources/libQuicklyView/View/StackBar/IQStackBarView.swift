//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackBarView : IQBarView {
    
    var inset: QInset { get }
    var leadingViews: [IQView] { get }
    var leadingViewSpacing: QFloat { get }
    var titleView: IQView? { get }
    var titleSpacing: QFloat { get }
    var detailView: IQView? { get }
    var detailSpacing: QFloat { get }
    var trailingViews: [IQView] { get }
    var trailingViewSpacing: QFloat { get }
    
    @discardableResult
    func inset(_ value: QInset) -> Self
    
    @discardableResult
    func leadingViews(_ value: [IQView]) -> Self
    
    @discardableResult
    func leadingViewSpacing(_ value: QFloat) -> Self
    
    @discardableResult
    func titleView(_ value: IQView?) -> Self
    
    @discardableResult
    func titleSpacing(_ value: QFloat) -> Self
    
    @discardableResult
    func detailView(_ value: IQView?) -> Self
    
    @discardableResult
    func detailSpacing(_ value: QFloat) -> Self
    
    @discardableResult
    func trailingViews(_ value: [IQView]) -> Self
    
    @discardableResult
    func trailingViewSpacing(_ value: QFloat) -> Self

}
