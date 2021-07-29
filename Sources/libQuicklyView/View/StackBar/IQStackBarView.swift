//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackBarView : IQBarView {
    
    var inset: QInset { set get }
    
    var leadingViews: [IQView] { set get }
    
    var leadingViewSpacing: Float { set get }
    
    var titleView: IQView? { set get }
    
    var titleSpacing: Float { set get }
    
    var detailView: IQView? { set get }
    
    var detailSpacing: Float { set get }
    
    var trailingViews: [IQView] { set get }
    
    var trailingViewSpacing: Float { set get }
    
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
