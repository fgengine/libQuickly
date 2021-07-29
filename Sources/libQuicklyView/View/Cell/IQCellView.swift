//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCellView : IQView, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var shouldHighlighting: Bool { set get }
    
    var shouldPressed: Bool { set get }
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func shouldPressed(_ value: Bool) -> Self
    
}
