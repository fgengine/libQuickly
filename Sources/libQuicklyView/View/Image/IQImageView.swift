//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QImageViewMode {
    case origin
    case aspectFit
    case aspectFill
}

public protocol IQImageView : IQView, IQViewColorable, IQViewTintColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour? { set get }
    
    var height: QDimensionBehaviour? { set get }
    
    var aspectRatio: Float? { set get }
    
    var image: QImage { set get }
    
    var mode: QImageViewMode { set get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func aspectRatio(_ value: Float?) -> Self
    
    @discardableResult
    func image(_ value: QImage) -> Self
    
    @discardableResult
    func mode(_ value: QImageViewMode) -> Self

}
