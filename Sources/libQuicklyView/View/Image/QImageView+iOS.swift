//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QImageView {
    
    final class ImageView : UIImageView {
        
        typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
        
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        
        private unowned var _view: View?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.isUserInteractionEnabled = false
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension QImageView.ImageView {
    
    func update(view: QImageView) {
        self._view = view
        self.update(image: view.image)
        self.update(mode: view.mode)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(image: QImage) {
        self.image = image.native
    }
    
    func update(mode: QImageViewMode) {
        switch mode {
        case .origin: self.contentMode = .center
        case .aspectFit: self.contentMode = .scaleAspectFit
        case .aspectFill: self.contentMode = .scaleAspectFill
        }
    }
    
    func cleanup() {
        self._view = nil
    }
    
}

extension QImageView.ImageView : IQReusable {
    
    typealias Owner = QImageView
    typealias Content = QImageView.ImageView

    static var reuseIdentificator: String {
        return "QImageView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: CGRect.zero)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(owner: Owner, content: Content) {
        content.cleanup()
    }
    
}

#endif
