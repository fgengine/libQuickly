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
        self.update(tintColor: view.tintColor)
        self.update(contentTintColor: view.contentTintColor)
        self.update(color: view.color)
    }
    
    func update(items: [IQInputToolbarItem]) {
        let barItems = items.compactMap({ return $0.barItem })
        for barItem in barItems {
            barItem.target = self
            barItem.action = #selector(self._pressed(_:))
        }
        self.items = barItems
    }
    
    func update(size: QFloat) {
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
    
    func update(tintColor: QColor?) {
        self.barTintColor = tintColor?.native
    }
    
    func update(contentTintColor: QColor) {
        self.tintColor = contentTintColor.native
    }
    
}

private extension QInputToolbarView.InputToolbarView {
    
    @objc
    func _pressed(_ sender: UIBarButtonItem) {
        self.customDelegate?.pressed(barItem: sender)
    }
    
}

extension QInputToolbarView.InputToolbarView : IQReusable {
    
    typealias View = QInputToolbarView
    typealias Item = QInputToolbarView.InputToolbarView

    static var reuseIdentificator: String {
        return "QInputToolbarView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 44
        ))
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.update(view: view)
        item.customDelegate = view
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
        item.customDelegate = nil
    }
    
}


#endif
