//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGroupBarViewDelegate : AnyObject {
    
    func pressed(groupBar: IQGroupBarView, itemView: IQView)
    
}

public protocol IQGroupBarView : IQBarView {
    
    var delegate: IQGroupBarViewDelegate? { set get }
    var itemInset: QInset { get }
    var itemSpacing: QFloat { get }
    var itemViews: [IQBarItemView] { get }
    var selectedItemView: IQBarItemView? { get }
    
    @discardableResult
    func itemInset(_ value: QInset) -> Self
    
    @discardableResult
    func itemSpacing(_ value: QFloat) -> Self
    
    @discardableResult
    func itemViews(_ value: [IQBarItemView]) -> Self
    
    @discardableResult
    func selectedItemView(_ value: IQBarItemView?) -> Self

}
