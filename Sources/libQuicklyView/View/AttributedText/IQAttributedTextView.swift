//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQAttributedTextView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable {
    
    var width: QDimensionBehaviour? { get }
    var height: QDimensionBehaviour? { get }
    var text: NSAttributedString { get }
    var alignment: QTextAlignment { get }
    var lineBreak: QTextLineBreak { get }
    var numberOfLines: UInt { get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func text(_ value: NSAttributedString) -> Self
    
    @discardableResult
    func alignment(_ value: QTextAlignment) -> Self
    
    @discardableResult
    func lineBreak(_ value: QTextLineBreak) -> Self
    
    @discardableResult
    func numberOfLines(_ value: UInt) -> Self

}
