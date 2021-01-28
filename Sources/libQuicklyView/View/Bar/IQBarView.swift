//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQBarView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var safeArea: QInset { get }
    
    @discardableResult
    func safeArea(_ value: QInset) -> Self

}
