//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QInputToolbarView {
    
    final class InputToolbarView : UIToolbar {
        
        private var customDelegate: InputToolbarViewDelegate?
        
        private unowned var _view: QInputToolbarView?
                
        override init(frame: CGRect) {
            super.init(frame: frame)

            self.clipsToBounds = true
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension QInputToolbarView.InputToolbarView {
    
    func update(view: QInputToolbarView) {
        self._view = view
        self.update(items: view.items)
        self.update(size: view.size)
        self.update(translucent: view.isTranslucent)
        self.update(barTintColor: view.barTintColor)
        self.update(contentTintColor: view.contentTintColor)
        self.update(color: view.color)
        self.customDelegate = view
    }
    
    func update(items: [IQInputToolbarItem]) {
        let barItems = items.compactMap({ return $0.barItem })
        for barItem in barItems {
            barItem.target = self
            barItem.action = #selector(self._pressed(_:))
        }
        self.items = barItems
    }
    
    func update(size: Float) {
        self.frame = CGRect(
            origin: frame.origin,
            size: CGSize(
                width: frame.width,
                height: CGFloat(size)
            )
        )
    }
    
    func update(translucent: Bool) {
        self.isTranslucent = translucent
    }
    
    func update(barTintColor: QColor?) {
        self.barTintColor = barTintColor?.native
    }
    
    func update(contentTintColor: QColor) {
        self.tintColor = contentTintColor.native
    }
    
    func cleanup() {
        self.customDelegate = nil
        self._view = nil
    }
    
}

private extension QInputToolbarView.InputToolbarView {
    
    @objc
    func _pressed(_ sender: UIBarButtonItem) {
        self.customDelegate?.pressed(barItem: sender)
    }
    
}

extension QInputToolbarView.InputToolbarView : IQReusable {
    
    typealias Owner = QInputToolbarView
    typealias Content = QInputToolbarView.InputToolbarView

    static var reuseIdentificator: String {
        return "QInputToolbarView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 44
        ))
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(content: Content) {
        content.cleanup()
    }
    
}


#endif
