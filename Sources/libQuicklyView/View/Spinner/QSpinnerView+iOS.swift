//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QSpinnerView {
    
    final class SpinnerView : UIActivityIndicatorView {
        
        var qColor: QColor {
            set(value) { self.color = value.native }
            get { return QColor(self.color) }
        }
        var qIsAnimating: Bool {
            set(value) {
                guard self.isAnimating != value else { return }
                if value == true {
                    self.startAnimating()
                } else {
                    self.stopAnimating()
                }
            }
            get { return self.isAnimating }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init() {
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

extension QSpinnerView.SpinnerView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.alpha < 1
    }
    
    func updateBlending(superview: QNativeView) {
        if self.allowBlending() == true || superview.allowBlending() == true {
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
    }
    
}

extension QSpinnerView.SpinnerView : IQReusable {
    
    typealias View = QSpinnerView
    typealias Item = QSpinnerView.SpinnerView

    static var reuseIdentificator: String {
        return "QSpinnerView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qColor = view.color
        item.qIsAnimating = view.isAnimating
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
