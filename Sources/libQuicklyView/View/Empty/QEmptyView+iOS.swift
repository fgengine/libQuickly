//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QEmptyView {
    
    final class EmptyView : UIView {
        
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        
        private unowned var _view: QEmptyView?
        
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
    
}

extension QEmptyView.EmptyView : IQReusable {
    
    typealias View = QEmptyView
    typealias Item = QEmptyView.EmptyView

    static var reuseIdentificator: String {
        return "QEmptyView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item(frame: CGRect.zero)
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.update(view: view)
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
