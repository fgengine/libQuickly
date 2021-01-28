//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQTextView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour? { get }
    var height: QDimensionBehaviour? { get }
    var text: String { get }
    var textFont: QFont { get }
    var textColor: QColor { get }
    var alignment: QTextAlignment { get }
    var lineBreak: QTextLineBreak { get }
    var numberOfLines: UInt { get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func text(_ value: String) -> Self
    
    @discardableResult
    func textFont(_ value: QFont) -> Self
    
    @discardableResult
    func textColor(_ value: QColor) -> Self
    
    @discardableResult
    func alignment(_ value: QTextAlignment) -> Self
    
    @discardableResult
    func lineBreak(_ value: QTextLineBreak) -> Self
    
    @discardableResult
    func numberOfLines(_ value: UInt) -> Self

}
