//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQWebView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour { get }
    var height: QDimensionBehaviour { get }
    var contentInset: QInset { get }
    var request: URLRequest? { get }
    var isLoading: Bool { get }
    
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
