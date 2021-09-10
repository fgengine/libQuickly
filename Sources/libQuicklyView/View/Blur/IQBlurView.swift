//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public protocol IQBlurView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var style: UIBlurEffect.Style { set get }
    
    @discardableResult
    func style(_ value: UIBlurEffect.Style) -> Self
    
}

#endif
