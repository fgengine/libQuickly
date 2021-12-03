//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QRateViewState {
    
    public let image: QImage
    public let rate: Float
    
    public init(
        image: QImage,
        rate: Float
    ) {
        self.image = image
        self.rate = rate
    }
    
}

public protocol IQRateView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var itemSize: QSize { set get }
    
    var itemSpacing: Float { set get }
    
    var numberOfItem: UInt { set get }
    
    var states: [QRateViewState] { set get }
    
    var rating: Float { set get }
    
    @discardableResult
    func itemSize(_ value: QSize) -> Self
    
    @discardableResult
    func itemSpacing(_ value: Float) -> Self
    
    @discardableResult
    func numberOfItem(_ value: UInt) -> Self
    
    @discardableResult
    func states(_ value: [QRateViewState]) -> Self
    
    @discardableResult
    func rating(_ value: Float) -> Self
    
}
