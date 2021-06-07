//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QEmptyView {
    
    final class EmptyView : UIView {
        
        typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
        
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
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QEmptyView.EmptyView {
    
    func update(view: QEmptyView) {
        self._view = view
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func cleanup() {
        self._view = nil
    }
    
}

extension QEmptyView.EmptyView : IQReusable {
    
    typealias Owner = QEmptyView
    typealias Content = QEmptyView.EmptyView

    static var reuseIdentificator: String {
        return "QEmptyView"
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
