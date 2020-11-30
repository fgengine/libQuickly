//
//  libQuicklyView
//

#if os(OSX)

import AppKit
import libQuicklyCore

extension QInputStringView {
    
    final class InputStringView : NSTextField {
        
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
        var qInset: QInset {
            set(value) { self._cell.inset = value.nsEdgeInsets }
            get { return QInset(self._cell.inset) }
        }
        var qEditingColor: QColor!
        var qPlaceholder: QInputPlaceholder? {
            didSet {
                if let placeholder = self.qPlaceholder {
                    self.placeholderAttributedString = NSAttributedString(string: placeholder.text, attributes: [
                        .font: placeholder.font.native,
                        .foregroundColor: placeholder.color.native
                    ])
                } else {
                    self.placeholderAttributedString = nil
                }
            }
        }
        var qPlaceholderInset: QInset? {
            set(value) { self._cell.placeholderInset = value?.nsEdgeInsets }
            get {
                guard let placeholderInset = self._cell.placeholderInset else { return nil }
                return QInset(placeholderInset)
            }
        }
        var qAlignment: QTextAlignment {
            set(value) { self.alignment = value.nsTextAlignment }
            get { return QTextAlignment(self.alignment) }
        }
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        override var effectiveAppearance: NSAppearance {
            return NSAppearance()
        }
        
        private var _cell: InputStringCell
        
        init() {
            self._cell = InputStringCell()
            self._cell.usesSingleLineMode = true
            self._cell.isScrollable = true
            self._cell.wraps = false
            
            super.init(frame: .zero)
            
            self.cell = self._cell
            self.drawsBackground = false
            self.isSelectable = true
            self.isEditable = true
            self.maximumNumberOfLines = 1
            self.lineBreakMode = .byClipping
            self.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func becomeFirstResponder() -> Bool {
            let success = super.becomeFirstResponder()
            if success == true {
                if let textView = self.currentEditor() as? NSTextView {
                    textView.insertionPointColor = self.qEditingColor.native
                    textView.selectedTextAttributes = [
                        .backgroundColor: textView.insertionPointColor
                    ]
                }
            }
            return success
        }
        
    }
    
    final class InputStringCell : NSTextFieldCell {
        
        var inset: NSEdgeInsets = NSEdgeInsets()
        var placeholderInset: NSEdgeInsets?
        
        func adjustedFrame(rect: NSRect) -> NSRect {
            let originTitleRect = super.titleRect(forBounds: rect)
            let titleInset = self.isHighlighted == true ? self.placeholderInset ?? self.inset : self.inset
            let titleRect = NSRect(
                x: originTitleRect.origin.x + CGFloat(titleInset.left),
                y: originTitleRect.origin.y + CGFloat(titleInset.top),
                width: originTitleRect.width + CGFloat(titleInset.left + titleInset.right),
                height: originTitleRect.height + CGFloat(titleInset.top + titleInset.bottom)
            )
            let cellSize = self.cellSize(forBounds: rect)
            return NSRect(
                x: titleRect.origin.x,
                y: (originTitleRect.height - cellSize.height) / 2,
                width: titleRect.width,
                height: cellSize.height 
            )
        }

        override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
            super.edit(withFrame: self.adjustedFrame(rect: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
        }

        override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
            super.select(withFrame: self.adjustedFrame(rect: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        }

        override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
            super.drawInterior(withFrame: self.adjustedFrame(rect: cellFrame), in: controlView)
        }
        
    }
        
}

extension QInputStringView.InputStringView : NSTextFieldDelegate {
}

extension QInputStringView.InputStringView : IQReusable {
    
    typealias View = QInputStringView
    typealias Item = QInputStringView.InputStringView

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
        item.qInset = view.inset
        item.qEditingColor = view.editingColor
        item.qPlaceholder = view.placeholder
        item.qPlaceholderInset = view.placeholderInset
        item.qAlignment = view.alignment
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
