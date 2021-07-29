//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCustomView : IQView, IQViewHighlightable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var gestures: [IQGesture] { set get }
    
    var contentSize: QSize { get }
    
    var shouldHighlighting: Bool { set get }
    
    @discardableResult
    func gestures(_ value: [IQGesture]) -> Self
    
    @discardableResult
    func add(gesture: IQGesture) -> Self
    
    @discardableResult
    func remove(gesture: IQGesture) -> Self
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self

}
