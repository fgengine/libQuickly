//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QWebViewRequest {
    
    case request(_ request: URLRequest)
    case file(url: URL, readAccess: URL)
    case html(string: String, baseUrl: URL?)
    case data(data: Data, mimeType: String, encoding: String, baseUrl: URL)
        
}

public enum QWebViewState {
    
    case empty
    case loading
    case loaded(_ error: Error?)
    
}

extension QWebViewState : Equatable {
    
    public static func == (lhs: QWebViewState, rhs: QWebViewState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty): return true
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        default: return false
        }
    }
    
}

public enum QWebViewNavigationPolicy {

    case cancel
    case allow
    
}

public protocol IQWebView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var contentInset: QInset { set get }
    
    var contentSize: QSize { get }
    
    var request: QWebViewRequest? { set get }
    
    var state: QWebViewState { get }
    
    func evaluate< Result >(javaScript: String, success: @escaping (Result) -> Void, failure: @escaping (Error) -> Void)
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func contentInset(_ value: QInset) -> Self
    
    @discardableResult
    func request(_ value: QWebViewRequest) -> Self
    
    @discardableResult
    func onContentSize(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onBeginLoading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndLoading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onDecideNavigation(_ value: ((_ request: URLRequest) -> QWebViewNavigationPolicy)?) -> Self

}
