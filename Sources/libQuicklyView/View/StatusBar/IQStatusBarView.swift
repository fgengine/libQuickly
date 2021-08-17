//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStatusBarView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var height: Float { set get }
    
    @discardableResult
    func height(_ value: Float) -> Self
    
}
