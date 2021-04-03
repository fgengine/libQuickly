//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCellView : IQView, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var shouldHighlighting: Bool { get }
    var shouldPressed: Bool { get }
    var contentView: IQView { get }
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func shouldPressed(_ value: Bool) -> Self
    
    @discardableResult
    func contentView(_ value: IQView) -> Self
    
}
