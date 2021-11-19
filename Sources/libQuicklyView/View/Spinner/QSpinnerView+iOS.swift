//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QSpinnerView {
    
    final class SpinnerView : UIActivityIndicatorView {
        
        typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
        
        private unowned var _view: View?
        
        override init(style: Style) {
            if #available(iOS 13.0, *) {
                super.init(style: .large)
            } else {
                super.init(style: .whiteLarge)
            }
            self.isUserInteractionEnabled = false
            self.hidesWhenStopped = true
            self.clipsToBounds = true
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension QSpinnerView.SpinnerView {
    
    func update(view: QSpinnerView) {
        self._view = view
        self.update(activityColor: view.activityColor)
        self.update(scaleFactor: view.scaleFactor)
        self.update(isAnimating: view.isAnimating)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(activityColor: QColor) {
        self.color = activityColor.native
    }
    
    func update(scaleFactor: Float) {
        self.transform = CGAffineTransform(scaleX: CGFloat(scaleFactor), y: CGFloat(scaleFactor))
    }
    
    func update(isAnimating: Bool) {
        if isAnimating == true {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }
    
    func cleanup() {
        self._view = nil
    }
    
}

extension QSpinnerView.SpinnerView : IQReusable {
    
    typealias Owner = QSpinnerView
    typealias Content = QSpinnerView.SpinnerView

    static var reuseIdentificator: String {
        return "QSpinnerView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        if #available(iOS 13.0, *) {
            return Content(style: .large)
        }
        return Content(style: .whiteLarge)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(content: Content) {
        content.cleanup()
    }
    
}

#endif
