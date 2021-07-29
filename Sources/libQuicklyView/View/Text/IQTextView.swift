//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQTextView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour? { set get }
    
    var height: QDimensionBehaviour? { set get }
    
    var text: String { set get }
    
    var textFont: QFont { set get }
    
    var textColor: QColor { set get }
    
    var alignment: QTextAlignment { set get }
    
    var lineBreak: QTextLineBreak { set get }
    
    var numberOfLines: UInt { set get }
    
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
