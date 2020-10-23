//
//  libQuicklyView
//

#if os(OSX)

import AppKit

extension QInputTextView {
    
    final class InputTextView : NSScrollView {
        
        var qText: String {
            set(value) { self._textView.string = value }
            get { return self._textView.string }
        }
        var qFont: QFont {
            set(value) { self._textView.font = value.native }
            get { return QFont(self._textView.font!) }
        }
        var qColor: QColor {
            set(value) { self._textView.textColor = value.native }
            get { return QColor(self._textView.textColor!) }
        }
        var qInset: QInset {
            set(value) { self.contentInsets = value.nsEdgeInsets }
            get { return QInset(self.contentInsets) }
        }
        var qEditingColor: QColor {
            set(value) {
                self._textView.insertionPointColor = value.native
                self._textView.selectedTextAttributes = [
                    .backgroundColor: self._textView.insertionPointColor
                ]
            }
            get { return QColor(self._textView.insertionPointColor) }
        }
        var qPlaceholder: QInputPlaceholder? {
            didSet {
                if let placeholder = self.qPlaceholder {
                    self._textView.placeholderAttributedString = NSAttributedString(string: placeholder.text, attributes: [
                        .font: placeholder.font.native,
                        .foregroundColor: placeholder.color.native
                    ])
                } else {
                    self._textView.placeholderAttributedString = nil
                }
            }
        }
        var qPlaceholderInset: QInset? {
            didSet { self.needsLayout = true }
        }
        var qAlignment: QTextAlignment {
            set(value) { self._textView.alignment = value.nsTextAlignment }
            get { return QTextAlignment(self._textView.alignment) }
        }
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _textStorage: NSTextStorage
        private var _layoutManager: NSLayoutManager
        private var _textContainer: NSTextContainer
        private var _textView: InputTextContainerView!
        
        init() {
            self._textStorage = NSTextStorage()
            self._layoutManager = NSLayoutManager()
            self._textContainer = NSTextContainer()
            
            self._textStorage.addLayoutManager(self._layoutManager)
            self._layoutManager.addTextContainer(self._textContainer)
            
            super.init(frame: .zero)

            self.backgroundColor = .clear
            self.drawsBackground = false
            self.borderType = .noBorder
            self.hasVerticalScroller = true
            self.autohidesScrollers = true
            
            self._textContainer.containerSize = CGSize(width: self.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
            self._textContainer.widthTracksTextView = true

            self._textView = InputTextContainerView(frame: .zero, textContainer: self._textContainer)
            self._textView.backgroundColor = .clear
            self._textView.autoresizingMask = [ .width ]
            self._textView.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
            self._textView.minSize = CGSize(width: 0, height: 0)
            self._textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            self._textView.textContainerInset = NSSize()
            self._textView.isVerticallyResizable = true

            self.documentView = self._textView
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    final class InputTextContainerView : NSTextView {
        
        @objc var placeholderAttributedString: NSAttributedString?
        
    }
        
}

extension QInputTextView.InputTextView : NSTextViewDelegate {
}

extension QInputTextView.InputTextView : IQReusable {
    
    typealias View = QInputTextView
    typealias Item = QInputTextView.InputTextView

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
