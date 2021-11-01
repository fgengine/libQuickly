//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QBarViewPlacement {
    case top
    case bottom
}

public protocol IQBarView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var placement: QBarViewPlacement { set get }
    
    var size: Float? { set get }
    
    var safeArea: QInset { set get }
    
    var separatorView: IQView? { set get }
    
    @discardableResult
    func placement(_ value: QBarViewPlacement) -> Self
    
    @discardableResult
    func size(_ value: Float?) -> Self
    
    @discardableResult
    func safeArea(_ value: QInset) -> Self
    
    @discardableResult
    func separatorView(_ value: IQView?) -> Self

}
