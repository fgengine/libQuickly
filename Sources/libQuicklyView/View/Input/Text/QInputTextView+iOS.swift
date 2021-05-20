//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QInputTextView {
    
    final class InputTextView : UIView {
        
        typealias View = IQInputTextView
        
        unowned var customDelegate: InputTextViewDelegate?
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        
        private unowned var _view: View?
        private var _placeholder: UILabel!
        private var _input: UITextView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
            
            self._placeholder = UILabel()
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
            if let view = self._view {
                let placeholderInset = view.placeholderInset ?? view.textInset
                let placeholderFrame = bounds.inset(by: placeholderInset.uiEdgeInsets)
                let placeholderSize = self._placeholder.sizeThatFits(placeholderFrame.size)
                self._placeholder.frame = CGRect(
                    origin: placeholderFrame.origin,
                    size: CGSize(width: placeholderFrame.width, height: placeholderSize.height)
                )
            } else {
                self._placeholder.frame = bounds
            }
            self._input.frame = bounds
        }
        
    }
    
}

extension QInputTextView.InputTextView {
    
    func update(view: QInputTextView) {
        self._view = view
        self.update(text: view.text)
        self.update(textFont: view.textFont)
        self.update(textColor: view.textColor)
        self.update(textInset: view.textInset)
        self.update(editingColor: view.editingColor)
        self.update(placeholder: view.placeholder)
        self.update(placeholderInset: view.placeholderInset)
        self.update(alignment: view.alignment)
        self.update(toolbar: view.toolbar)
        self.update(keyboard: view.keyboard)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
        self.customDelegate = view
    }
    
    func update(text: String) {
        self._input.text = text
    }
    
    func update(textFont: QFont) {
        self._input.font = textFont.native
    }
    
    func update(textColor: QColor) {
        self._input.textColor = textColor.native
    }
    
    func update(textInset: QInset) {
        self._input.setNeedsLayout()
    }
    
    func update(editingColor: QColor) {
        self._input.tintColor = editingColor.native
    }
    
    func update(placeholder: QInputPlaceholder) {
        self._placeholder.text = placeholder.text
        self._placeholder.font = placeholder.font.native
        self._placeholder.textColor = placeholder.color.native
        self._placeholder.isHidden = self._input.text.isEmpty == false
    }
    
    func update(placeholderInset: QInset?) {
        self.setNeedsLayout()
    }
    
    func update(alignment: QTextAlignment) {
        self._input.textAlignment = alignment.nsTextAlignment
        self._placeholder.textAlignment = alignment.nsTextAlignment
    }
    
    func update(toolbar: IQInputToolbarView?) {
        self._input.inputAccessoryView = toolbar?.native
    }
    
    func update(keyboard: QInputKeyboard?) {
        self._input.keyboardType = keyboard?.type ?? .default
        self._input.keyboardAppearance = keyboard?.appearance ?? .default
        self._input.autocapitalizationType = keyboard?.autocapitalization ?? .sentences
        self._input.autocorrectionType = keyboard?.autocorrection ?? .default
        self._input.spellCheckingType = keyboard?.spellChecking ?? .default
        self._input.returnKeyType = keyboard?.returnKey ?? .default
        self._input.enablesReturnKeyAutomatically = keyboard?.enablesReturnKeyAutomatically ?? true
        if #available(iOS 10.0, *) {
            self._input.textContentType = keyboard?.textContent
        }
    }
    
    func cleanup() {
        self.customDelegate = nil
        self._view = nil
    }
    
}

extension QInputTextView.InputTextView : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.customDelegate?.beginEditing()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let sourceText = (textView.text ?? "") as NSString
        let newText = sourceText.replacingCharacters(in: range, with: text)
        self.customDelegate?.editing(text: newText)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self._placeholder.isHidden = textView.text.isEmpty == false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.customDelegate?.endEditing()
    }

}

extension QInputTextView.InputTextView : IQReusable {
    
    typealias Owner = QInputTextView
    typealias Content = QInputTextView.InputTextView

    static var reuseIdentificator: String {
        return "QInputTextView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: .zero)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(owner: Owner, content: Content) {
        content.cleanup()
    }
    
}

#endif
