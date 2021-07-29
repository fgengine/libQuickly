//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQControlView : IQView, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var contentSize: QSize { get }
    
    var shouldHighlighting: Bool { set get }
    
    var shouldPressed: Bool { set get }
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func shouldPressed(_ value: Bool) -> Self
    
    @discardableResult
    func onPressed(_ value: (() -> Void)?) -> Self
    
}
