//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public protocol IQRemoteImageView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var isLoading: Bool { get }
    var placeholderView: IQImageView { set get }
    var imageView: IQImageView? { get }
    var progressView: IQProgressView? { set get }
    var errorView: IQView? { set get }
    var loader: QRemoteImageLoader { get }
    var query: IQRemoteImageQuery { set get }
    var filter: IQRemoteImageFilter? { set get }
    
    @discardableResult
    func startLoading() -> Self
    
    @discardableResult
    func stopLoading() -> Self
    
    @discardableResult
    func placeholderView(_ value: IQImageView) -> Self
    
    @discardableResult
    func progressView(_ value: IQProgressView?) -> Self
    
    @discardableResult
    func errorView(_ value: IQView?) -> Self
    
    @discardableResult
    func query(_ value: IQRemoteImageQuery) -> Self
    
    @discardableResult
    func filter(_ value: IQRemoteImageFilter?) -> Self
    
    @discardableResult
    func onProgress(_ value: ((_ progress: Float) -> Void)?) -> Self
    
    @discardableResult
    func onFinish(_ value: ((_ image: QImage) -> IQImageView)?) -> Self
    
    @discardableResult
    func onError(_ value: ((_ error: Error) -> Void)?) -> Self

}
