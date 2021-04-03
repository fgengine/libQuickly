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
    
    var inset: QInset { get }
    var backgroundView: IQView { get }
    var spinnerPosition: QButtonViewSpinnerPosition { get }
    var spinnerAnimating: Bool { get }
    var spinnerView: IQSpinnerView? { get }
    var imagePosition: QButtonViewImagePosition { get }
    var imageInset: QInset { get }
    var imageView: IQView? { get }
    var textInset: QInset { get }
    var textView: IQView? { get }
    
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
