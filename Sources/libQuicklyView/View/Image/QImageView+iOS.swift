//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QImageView {
    
    final class ImageView : UIImageView {
        
        var qImage: QImage {
            set(value) { self.image = value.native }
            get { return QImage(self.image!) }
        }
        var qMode: Mode {
            set(value) { self.contentMode = value.uiViewContentMode }
            get { return Mode(self.contentMode) }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init() {
            super.init(frame: .zero)
            
            self.isUserInteractionEnabled = false
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension QImageView.ImageView : IQNativeBlendingView {
    
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

extension QImageView.Mode {
    
    var uiViewContentMode: UIView.ContentMode {
        switch self {
        case .origin: return .center
        case .aspectFit: return .scaleAspectFit
        case .aspectFill: return .scaleAspectFill
        }
    }
    
    init(_ uiViewContentMode: UIView.ContentMode) {
        switch uiViewContentMode {
        case .scaleAspectFit: self = .aspectFit
        case .scaleAspectFill: self = .aspectFill
        default: self = .origin
        }
    }
    
}

extension QImageView.ImageView : IQReusable {
    
    typealias View = QImageView
    typealias Item = QImageView.ImageView

    static var reuseIdentificator: String {
        return "QImageView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qImage = view.image
        item.qMode = view.mode
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
