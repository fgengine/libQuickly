//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QBlurView {
    
    final class BlurView : UIVisualEffectView {
        
        var qStyle: UIBlurEffect.Style {
            didSet(oldValue) {
                if self.qStyle != oldValue {
                    self.effect = UIBlurEffect(style: self.qStyle)
                }
            }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init(style: UIBlurEffect.Style) {
            self.qStyle = style
            
            super.init(effect: UIBlurEffect(style: style))
            
            self.backgroundColor = .clear
            self.isUserInteractionEnabled = false
            self.clipsToBounds = true
            self.isOpaque = false
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension QBlurView.BlurView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return true
    }
    
    func updateBlending(superview: QNativeView) {
    }
    
}

extension QBlurView.BlurView : IQReusable {
    
    typealias View = QBlurView
    typealias Item = QBlurView.BlurView

    static var reuseIdentificator: String {
        return "QBlurView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item(style: view.style)
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qStyle = view.style
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
