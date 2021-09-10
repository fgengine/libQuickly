//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QAnimatedImageViewRepeat {
    case loops(_ count: Int)
    case infinity
}

public enum QAnimatedImageViewMode {
    case origin
    case aspectFit
    case aspectFill
}

public protocol IQAnimatedImageView : IQView, IQViewColorable, IQViewTintColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour? { set get }
    
    var height: QDimensionBehaviour? { set get }
    
    var aspectRatio: Float? { set get }
    
    var images: [QImage] { set get }
    
    var duration: TimeInterval { set get }
    
    var `repeat`: QAnimatedImageViewRepeat { set get }
    
    var mode: QAnimatedImageViewMode { set get }
    
    var isAnimating: Bool { get }
    
    @discardableResult
    func start() -> Self

    @discardableResult
    func stop() -> Self
    
    @discardableResult
    func width(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func aspectRatio(_ value: Float?) -> Self
    
    @discardableResult
    func images(_ value: [QImage]) -> Self
    
    @discardableResult
    func duration(_ value: TimeInterval) -> Self
    
    @discardableResult
    func `repeat`(_ value: QAnimatedImageViewRepeat) -> Self
    
    @discardableResult
    func mode(_ value: QAnimatedImageViewMode) -> Self

}
