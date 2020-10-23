//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QAttributedTextView {
    
    final class AttributedTextView : UILabel {
        
        var qText: NSAttributedString? {
            set(value) { self.attributedText = value }
            get { return self.attributedText }
        }
        var qAlignment: QTextAlignment {
            set(value) { self.textAlignment = value.nsTextAlignment }
            get { return QTextAlignment(self.textAlignment) }
        }
        var qLineBreak: QTextLineBreak {
            set(value) { self.lineBreakMode = value.nsLineBreakMode }
            get { return QTextLineBreak(self.lineBreakMode) }
        }
        var qNumberOfLines: UInt {
            set(value) { self.numberOfLines = Int(value) }
            get { return UInt(self.numberOfLines) }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init() {
            super.init(frame: CGRect.zero)
            
            self.isUserInteractionEnabled = false
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QAttributedTextView.AttributedTextView : IQNativeBlendingView {
    
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

extension QAttributedTextView.AttributedTextView : IQReusable {
    
    typealias View = QAttributedTextView
    typealias Item = QAttributedTextView.AttributedTextView

    static var reuseIdentificator: String {
        return "QAttributedTextView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qText = view.text
        item.qAlignment = view.alignment
        item.qLineBreak = view.lineBreak
        item.qNumberOfLines = view.numberOfLines
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
