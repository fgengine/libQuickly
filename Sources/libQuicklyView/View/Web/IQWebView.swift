//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQWebView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var contentInset: QInset { set get }
    
    var request: URLRequest? { set get }
    
    var isLoading: Bool { set get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func contentInset(_ value: QInset) -> Self
    
    @discardableResult
    func request(_ value: URLRequest) -> Self
    
    @discardableResult
    func onBeginLoading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndLoading(_ value: (() -> Void)?) -> Self

}
