//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQControlView : IQView, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    associatedtype Layout : IQLayout
    
    var layout: Layout { get }
    var contentSize: QSize { get }
    var shouldHighlighting: Bool { get }
    var shouldPressed: Bool { get }
    
    @discardableResult
    func layout(_ value: Layout) -> Self
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func shouldPressed(_ value: Bool) -> Self
    
    @discardableResult
    func onPressed(_ value: (() -> Void)?) -> Self
    
}
