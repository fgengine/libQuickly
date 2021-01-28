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

public protocol IQImageView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour? { get }
    var height: QDimensionBehaviour? { get }
    var image: QImage { get }
    var mode: QImageViewMode { get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour?) -> Self
    
    @discardableResult
    func image(_ value: QImage) -> Self
    
    @discardableResult
    func mode(_ value: QImageViewMode) -> Self

}
