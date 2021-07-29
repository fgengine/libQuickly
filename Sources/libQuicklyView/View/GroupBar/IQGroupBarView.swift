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
    
    var itemInset: QInset { set get }
    
    var itemSpacing: Float { set get }
    
    var itemViews: [IQBarItemView] { set get }
    
    var selectedItemView: IQBarItemView? { set get }
    
    @discardableResult
    func itemInset(_ value: QInset) -> Self
    
    @discardableResult
    func itemSpacing(_ value: Float) -> Self
    
    @discardableResult
    func itemViews(_ value: [IQBarItemView]) -> Self
    
    @discardableResult
    func selectedItemView(_ value: IQBarItemView?) -> Self

}
