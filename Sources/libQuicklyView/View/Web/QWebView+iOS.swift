//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import WebKit
import libQuicklyCore

extension QWebView {
    
    final class WebView : WKWebView {
        
        typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
        
        unowned var customDelegate: WebViewDelegate?
        override var frame: CGRect {
            set(value) {
                if super.frame != value {
                    super.frame = value
                    if let view = self._view {
                        self.update(cornerRadius: view.cornerRadius)
                        self.updateShadowPath()
                    }
                }
            }
            get { return super.frame }
        }
        
        private unowned var _view: View?
        
        override init(frame: CGRect, configuration: WKWebViewConfiguration) {
            super.init(frame: frame, configuration: configuration)

            if #available(iOS 11.0, *) {
                self.scrollView.contentInsetAdjustmentBehavior = .never
            }
            self.clipsToBounds = true
            self.navigationDelegate = self
            self.uiDelegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QWebView.WebView {
    
    func update(view: QWebView) {
        self._view = view
        self.update(contentInset: view.contentInset)
        self.update(request: view.request)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
        self.customDelegate = view
    }
    
    func update(contentInset: QInset) {
        self.scrollView.contentInset = contentInset.uiEdgeInsets
        self.scrollView.scrollIndicatorInsets = contentInset.uiEdgeInsets
    }
    
    func update(request: URLRequest?) {
        if let request = request {
            self.load(request)
            self.customDelegate?.beginLoading()
        } else {
            self.stopLoading()
        }
    }
    
    func cleanup() {
        self.customDelegate = nil
        self._view = nil
        self.load(URLRequest(url: URL(string: "about:blank")!))
    }
    
}

extension QWebView.WebView : UIScrollViewDelegate {
}

extension QWebView.WebView : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.customDelegate?.endLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.customDelegate?.endLoading()
    }
    
}

extension QWebView.WebView : WKUIDelegate {
}

extension QWebView.WebView : IQReusable {
    
    typealias Owner = QWebView
    typealias Content = QWebView.WebView

    static var reuseIdentificator: String {
        return "QWebView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: .zero)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(owner: Owner, content: Content) {
        content.cleanup()
    }
    
}

#endif
