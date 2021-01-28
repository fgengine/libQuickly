//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCustomView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var gestures: [IQGesture] { get }
    var layout: IQLayout { get }
    var contentSize: QSize { get }
    var shouldHighlighting: Bool { get }
    var isHighlighted: Bool { get }
    
    @discardableResult
    func gestures(_ value: [IQGesture]) -> Self
    
    @discardableResult
    func add(gesture: IQGesture) -> Self
    
    @discardableResult
    func remove(gesture: IQGesture) -> Self
    
    @discardableResult
    func layout(_ value: IQLayout) -> Self
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func isHighlighted(_ value: Bool) -> Self
    
    @discardableResult
    func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self

}
