//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQBarItemViewDelegate : AnyObject {
    
    func pressed(barItemView: IQBarItemView)
    
}

public protocol IQBarItemView : IQView, IQViewSelectable, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var delegate: IQBarItemViewDelegate? { set get }
    
    var contentInset: QInset { set get }
    
    var contentView: IQView { set get }
    
    @discardableResult
    func contentInset(_ value: QInset) -> Self

}
