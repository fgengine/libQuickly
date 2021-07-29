//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public protocol IQRemoteImageView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var isLoading: Bool { get }
    var imageView: IQImageView { get }
    var progressView: IQProgressView? { get }
    var errorView: IQView? { get }
    var loader: QRemoteImageLoader { get }
    var query: IQRemoteImageQuery { get }
    var filter: IQRemoteImageFilter? { get }
    
    @discardableResult
    func startLoading() -> Self
    
    @discardableResult
    func stopLoading() -> Self
    
    @discardableResult
    func imageView(_ value: IQImageView) -> Self
    
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
    func onFinish(_ value: ((_ image: QImage) -> Void)?) -> Self
    
    @discardableResult
    func onError(_ value: ((_ error: Error) -> Void)?) -> Self

}
