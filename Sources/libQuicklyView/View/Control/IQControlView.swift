//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQControlView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var layout: IQLayout { get }
    var contentSize: QSize { get }
    var shouldHighlighting: Bool { get }
    var isHighlighted: Bool { get }
    var shouldPressed: Bool { get }
    
    @discardableResult
    func layout(_ value: IQLayout) -> Self
    
    @discardableResult
    func shouldHighlighting(_ value: Bool) -> Self
    
    @discardableResult
    func highlighted(_ value: Bool) -> Self
    
    @discardableResult
    func shouldPressed(_ value: Bool) -> Self
    
    @discardableResult
    func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self
    
    @discardableResult
    func onPressed(_ value: (() -> Void)?) -> Self
    
}
