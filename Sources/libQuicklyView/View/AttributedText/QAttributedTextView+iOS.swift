//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QAttributedTextView {
    
    final class AttributedTextView : UILabel {
        
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        
        private unowned var _view: QAttributedTextView?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QAttributedTextView.AttributedTextView {
    
    func update(view: QAttributedTextView) {
        self._view = view
        self.update(text: view.text)
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
    
    func update(text: NSAttributedString) {
        self.attributedText = text
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

extension QAttributedTextView.AttributedTextView : IQReusable {
    
    typealias View = QAttributedTextView
    typealias Item = QAttributedTextView.AttributedTextView

    static var reuseIdentificator: String {
        return "QAttributedTextView"
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
