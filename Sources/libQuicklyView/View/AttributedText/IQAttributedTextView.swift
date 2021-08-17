//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQAttributedTextView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour? { set get }
    
    var height: QDimensionBehaviour? { set get }
    
    var text: NSAttributedString { set get }
    
    var alignment: QTextAlignment? { set get }
    
    var lineBreak: QTextLineBreak { set get }
    
    var numberOfLines: UInt { set get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func text(_ value: NSAttributedString) -> Self
    
    @discardableResult
    func alignment(_ value: QTextAlignment?) -> Self
    
    @discardableResult
    func lineBreak(_ value: QTextLineBreak) -> Self
    
    @discardableResult
    func numberOfLines(_ value: UInt) -> Self
    
    @discardableResult
    func onTap(_ value: ((_ attributes: [NSAttributedString.Key: Any]?) -> Void)?) -> Self

}
