//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QTextView {
    
    final class TextView : UILabel {
        
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        
        private unowned var _view: QTextView?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QTextView.TextView {
    
    func update(view: QTextView) {
        self._view = view
        self.update(text: view.text)
        self.update(textFont: view.textFont)
        self.update(textColor: view.textColor)
        self.update(alignment: view.alignment)
        self.update(lineBreak: view.lineBreak)
        self.update(numberOfLines: view.numberOfLines)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(text: String) {
        self.text = text
    }
    
    func update(textFont: QFont) {
        self.font = textFont.native
    }
    
    func update(textColor: QColor) {
        self.textColor = textColor.native
    }
    
    func update(alignment: QTextAlignment) {
        self.textAlignment = alignment.nsTextAlignment
    }
    
    func update(lineBreak: QTextLineBreak) {
        self.lineBreakMode = lineBreak.nsLineBreakMode
    }
    
    func update(numberOfLines: UInt) {
        self.numberOfLines = Int(numberOfLines)
    }
    
}

extension QTextView.TextView : IQReusable {
    
    typealias View = QTextView
    typealias Item = QTextView.TextView

    static var reuseIdentificator: String {
        return "QTextView"
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
