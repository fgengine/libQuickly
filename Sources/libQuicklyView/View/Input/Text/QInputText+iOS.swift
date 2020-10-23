//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public extension QInputTextView {
    
    struct ToolbarAction : QInputToolbarItem {
        
        public var callback: (_ sender: QInputTextView) -> Void
        public var barItem: UIBarButtonItem
        
        public init(
            text: String,
            callback: @escaping (_ sender: QInputTextView) -> Void
        ) {
            self.callback = callback
            self.barItem = UIBarButtonItem()
            self.barItem.title = text
        }
        
        public init(
            image: QImage,
            callback: @escaping (_ sender: QInputTextView) -> Void
        ) {
            self.callback = callback
            self.barItem = UIBarButtonItem()
            self.barItem.image = image.native
        }
        
        public init(
            systemItem: UIBarButtonItem.SystemItem,
            callback: @escaping (_ sender: QInputTextView) -> Void
        ) {
            self.callback = callback
            self.barItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        }
        
    }
    
}

extension QInputTextView {
    
    final class InputTextView : UIView {
        
        weak var qDelegate: InputTextViewDelegate?
        var qText: String {
            set(value) {
                self._input.text = value
                self._placeholder.isHidden = value.isEmpty == false
            }
            get { return self._input.text ?? "" }
        }
        var qFont: QFont {
            set(value) { self._input.font = value.native }
            get { return QFont(self._input.font!) }
        }
        var qColor: QColor {
            set(value) { self._input.textColor = value.native }
            get { return QColor(self._input.textColor!) }
        }
        var qInset: QInset {
            set(value) { self._input.textContainerInset = value.uiEdgeInsets }
            get { return QInset(self._input.textContainerInset) }
        }
        var qEditingColor: QColor {
            set(value) { self._input.tintColor = value.native }
            get { return QColor(self._input.tintColor!) }
        }
        var qPlaceholder: QInputPlaceholder? {
            didSet {
                if let placeholder = self.qPlaceholder {
                    self._placeholder.text = placeholder.text
                    self._placeholder.font = placeholder.font.native
                    self._placeholder.textColor = placeholder.color.native
                } else {
                    self._placeholder.text = ""
                }
                self._placeholder.isHidden = self._input.text.isEmpty == false
            }
        }
        var qPlaceholderInset: QInset? {
            didSet { self.setNeedsLayout() }
        }
        var qAlignment: QTextAlignment {
            set(value) {
                self._placeholder.textAlignment = value.nsTextAlignment
                self._input.textAlignment = self._placeholder.textAlignment
            }
            get { return QTextAlignment(self._input.textAlignment) }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qToolbar: IQAccessoryView? {
            didSet {
                self._input.inputAccessoryView = self.qToolbar?.native
            }
        }
        var qKeyboard: QInputKeyboard {
            set(value) {
                self._input.keyboardType = value.type
                self._input.keyboardAppearance = value.appearance
                self._input.autocapitalizationType = value.autocapitalization
                self._input.autocorrectionType = value.autocorrection
                self._input.spellCheckingType = value.spellChecking
                self._input.returnKeyType = value.returnKey
                self._input.enablesReturnKeyAutomatically = value.enablesReturnKeyAutomatically
                if #available(iOS 10.0, *) {
                    self._input.textContentType = value.textContent
                }
            }
            get {
                if #available(iOS 10.0, *) {
                    return QInputKeyboard(
                        type: self._input.keyboardType,
                        appearance: self._input.keyboardAppearance,
                        autocapitalization: self._input.autocapitalizationType,
                        autocorrection: self._input.autocorrectionType,
                        spellChecking: self._input.spellCheckingType,
                        returnKey: self._input.returnKeyType,
                        enablesReturnKeyAutomatically: self._input.enablesReturnKeyAutomatically,
                        textContent: self._input.textContentType
                    )
                } else {
                    return QInputKeyboard(
                        type: self._input.keyboardType,
                        appearance: self._input.keyboardAppearance,
                        autocapitalization: self._input.autocapitalizationType,
                        autocorrection: self._input.autocorrectionType,
                        spellChecking: self._input.spellCheckingType,
                        returnKey: self._input.returnKeyType,
                        enablesReturnKeyAutomatically: self._input.enablesReturnKeyAutomatically
                    )
                }
            }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _input: UITextView!
        private var _placeholder: PlaceholderView!
        
        init() {
            super.init(frame: .zero)

            self.clipsToBounds = true
            
            self._placeholder = PlaceholderView()
            self._placeholder.isHidden = true
            self.addSubview(self._placeholder)
            
            self._input = UITextView()
            self._input.backgroundColor = .clear
            self._input.textContainer.lineFragmentPadding = 0
            self._input.layoutManager.usesFontLeading = true
            self._input.delegate = self
            self.addSubview(self._input)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            let placeholderInset = self.qPlaceholderInset ?? self.qInset
            let placeholderFrame = bounds.inset(by: placeholderInset.uiEdgeInsets)
            let placeholderSize = self._placeholder.sizeThatFits(placeholderFrame.size)
            self._placeholder.frame = CGRect(
                origin: placeholderFrame.origin,
                size: CGSize(width: placeholderFrame.width, height: placeholderSize.height)
            )
            self._input.frame = bounds
        }
        
    }
    
    final class PlaceholderView : UILabel {
        
        override var backgroundColor: UIColor? {
            didSet(oldValue) {
                guard self.backgroundColor != oldValue else { return }
                self.updateBlending()
            }
        }
        override var alpha: CGFloat {
            didSet(oldValue) {
                guard self.alpha != oldValue else { return }
                self.updateBlending()
            }
        }
        
    }
    
}

extension QInputTextView.InputTextView : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self._placeholder.isHidden = textView.text.isEmpty == false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.qDelegate?.beginEditing()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let sourceText = (textView.text ?? "") as NSString
        let newText = sourceText.replacingCharacters(in: range, with: text)
        self.qDelegate?.editing(text: newText)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.qDelegate?.endEditing()
    }

}

extension QInputTextView.InputTextView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.isOpaque == false
    }
    
    func updateBlending(superview: QNativeView) {
        if superview.allowBlending() == true {
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
        self.updateBlending()
    }
    
}

extension QInputTextView.PlaceholderView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.isOpaque == false
    }
    
    func updateBlending(superview: QNativeView) {
        if superview.allowBlending() == true {
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
        self.updateBlending()
    }
    
}

extension QInputTextView.InputTextView : IQReusable {
    
    typealias View = QInputTextView
    typealias Item = QInputTextView.InputTextView

    static var reuseIdentificator: String {
        return "QInputTextView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qText = view.text
        item.qFont = view.font
        item.qColor = view.color
        item.qInset = view.inset
        item.qEditingColor = view.editingColor
        item.qPlaceholder = view.placeholder
        item.qPlaceholderInset = view.placeholderInset
        item.qAlignment = view.alignment
        item.qAlpha = view.alpha
        item.qToolbar = view.toolbar
        item.qKeyboard = view.keyboard
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
