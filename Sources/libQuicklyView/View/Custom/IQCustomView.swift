//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCustomView : IQView, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    associatedtype Layout : IQLayout
    
    var gestures: [IQGesture] { get }
    var contentLayout: Layout { get }
    var contentSize: QSize { get }
    var shouldHighlighting: Bool { get }
    
    @discardableResult
    func gestures(_ value: [IQGesture]) -> Self
    
    @discardableResult
    func add(gesture: IQGesture) -> Self
    
    @discardableResult
    func remove(gesture: IQGesture) -> Self
    
    @discardableResult
    func contentLayout(_ value: Layout) -> Self
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self

}
