//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QInputToolbarView {
    
    final class InputToolbarView : UIToolbar {
        
        weak var qDelegate: InputToolbarViewDelegate?
        var qSize: QFloat {
            set(value) {
                let frame = super.frame
                super.frame = CGRect(
                    origin: frame.origin,
                    size: CGSize(
                        width: frame.width,
                        height: CGFloat(value)
                    )
                )
            }
            get { return QFloat(self.frame.height) }
        }
        var qItems: [IQInputToolbarItem]! {
            didSet {
                let items = self.qItems.compactMap({ return $0.barItem })
                for item in items {
                    item.target = self
                    item.action = #selector(self._pressed(_:))
                }
                self.items = items
            }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsTranslucent: Bool {
            set(value) { self.isTranslucent = value }
            get { return self.isTranslucent }
        }
        var qTintColor: QColor? {
            set(value) { self.barTintColor = value?.native }
            get { return self.barTintColor == nil ? nil : QColor(self.barTintColor!) }
        }
        var qContentTintColor: QColor {
            set(value) { self.tintColor = value.native }
            get { return QColor(self.tintColor!) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
                
        init() {
            super.init(frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 44
            ))

            self.clipsToBounds = true
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

private extension QInputToolbarView.InputToolbarView {
    
    @objc
    func _pressed(_ sender: UIBarButtonItem) {
        self.qDelegate?.pressed(barItem: sender)
    }
    
}

extension QInputToolbarView.InputToolbarView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.alpha < 1
    }
    
    func updateBlending(superview: QNativeView) {
        if superview.allowBlending() == true {
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
    }
    
}

extension QInputToolbarView.InputToolbarView : IQReusable {
    
    typealias View = QInputToolbarView
    typealias Item = QInputToolbarView.InputToolbarView

    static var reuseIdentificator: String {
        return "QInputToolbarView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qSize = view.size
        item.qItems = view.items
        item.qAlpha = view.alpha
        item.qIsTranslucent = view.isTranslucent
        item.qTintColor = view.tintColor
        item.qContentTintColor = view.contentTintColor
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}


#endif
