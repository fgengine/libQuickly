//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackBarView : IQBarView {
    
    var leadingViews: [IQView] { get }
    var titleView: IQView? { get }
    var detailView: IQView? { get }
    var trailingViews: [IQView] { get }
    
    @discardableResult
    func leadingViews(_ value: [IQView]) -> Self
    
    @discardableResult
    func titleView(_ value: IQView?) -> Self
    
    @discardableResult
    func detailView(_ value: IQView?) -> Self
    
    @discardableResult
    func trailingViews(_ value: [IQView]) -> Self

}
