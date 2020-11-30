//
//  libQuicklyView
//

#if os(OSX)

import AppKit
import libQuicklyCore

extension QTextView {
    
    final class TextView : NSTextField {
        
        var qText: String {
            set(value) { self.stringValue = value }
            get { return self.stringValue }
        }
        var qFont: QFont {
            set(value) { self.font = value.native }
            get { return QFont(self.font!) }
        }
        var qColor: QColor {
            set(value) { self.textColor = value.native }
            get { return QColor(self.textColor!) }
        }
        var qAlignment: QTextAlignment {
            set(value) { self.alignment = value.nsTextAlignment }
            get { return QTextAlignment(self.alignment) }
        }
        var qLineBreak: QTextLineBreak {
            set(value) { self.lineBreakMode = value.nsLineBreakMode }
            get { return QTextLineBreak(self.lineBreakMode) }
        }
        var qNumberOfLines: UInt {
            set(value) { self.maximumNumberOfLines = Int(value) }
            get { return UInt(self.maximumNumberOfLines) }
        }
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init() {
            super.init(frame: .zero)
            
            self.drawsBackground = false
            self.isBordered = false
            self.isBezeled = false
            self.isEditable = false
            self.isSelectable = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func hitTest(_ point: NSPoint) -> NSView? {
            return nil
        }
        
        override func alignmentRect(forFrame frame: NSRect) -> NSRect {
            return frame
        }
        
    }
        
}

extension QTextView.TextView : IQReusable {
    
    typealias View = QTextView
    typealias Item = QTextView.TextView

    static var reuseIdentificator: String {
        return "QTextView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qText = view.text
        item.qFont = view.font
        item.qColor = view.color
        item.qAlignment = view.alignment
        item.qLineBreak = view.lineBreak
        item.qNumberOfLines = view.numberOfLines
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
