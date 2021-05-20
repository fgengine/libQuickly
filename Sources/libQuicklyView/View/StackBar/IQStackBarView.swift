//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackBarView : IQBarView {
    
    var inset: QInset { get }
    var leadingViews: [IQView] { get }
    var leadingViewSpacing: Float { get }
    var titleView: IQView? { get }
    var titleSpacing: Float { get }
    var detailView: IQView? { get }
    var detailSpacing: Float { get }
    var trailingViews: [IQView] { get }
    var trailingViewSpacing: Float { get }
    
    @discardableResult
    func inset(_ value: QInset) -> Self
    
    @discardableResult
    func leadingViews(_ value: [IQView]) -> Self
    
    @discardableResult
    func leadingViewSpacing(_ value: Float) -> Self
    
    @discardableResult
    func titleView(_ value: IQView?) -> Self
    
    @discardableResult
    func titleSpacing(_ value: Float) -> Self
    
    @discardableResult
    func detailView(_ value: IQView?) -> Self
    
    @discardableResult
    func detailSpacing(_ value: Float) -> Self
    
    @discardableResult
    func trailingViews(_ value: [IQView]) -> Self
    
    @discardableResult
    func trailingViewSpacing(_ value: Float) -> Self

}
