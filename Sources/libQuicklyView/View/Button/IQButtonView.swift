//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QButtonViewSpinnerPosition {
    case fill
    case image
}

public enum QButtonViewImagePosition {
    case top
    case left
    case right
    case bottom
}

public protocol IQButtonView : IQView, IQViewHighlightable, IQViewSelectable, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var inset: QInset { set get }
    
    var backgroundView: IQView { set get }
    
    var spinnerPosition: QButtonViewSpinnerPosition { set get }
    
    var spinnerAnimating: Bool { set get }
    
    var spinnerView: IQSpinnerView? { set get }
    
    var imagePosition: QButtonViewImagePosition { set get }
    
    var imageInset: QInset { set get }
    
    var imageView: IQView? { set get }
    
    var textInset: QInset { set get }
    
    var textView: IQView? { set get }
    
    @discardableResult
    func inset(_ value: QInset) -> Self
    
    @discardableResult
    func spinnerPosition(_ value: QButtonViewSpinnerPosition) -> Self
    
    @discardableResult
    func spinnerAnimating(_ value: Bool) -> Self
    
    @discardableResult
    func imagePosition(_ value: QButtonViewImagePosition) -> Self
    
    @discardableResult
    func imageInset(_ value: QInset) -> Self
    
    @discardableResult
    func textInset(_ value: QInset) -> Self
    
    @discardableResult
    func onPressed(_ value: (() -> Void)?) -> Self

}
