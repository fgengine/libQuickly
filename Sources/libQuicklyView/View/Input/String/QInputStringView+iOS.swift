//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QInputStringView {
    
    final class InputStringView : UITextField {
        
        typealias View = IQInputStringView
        
        unowned var customDelegate: InputStringViewDelegate?
        override var frame: CGRect {
            set(value) {
                if super.frame != value {
                    super.frame = value
                    if let view = self._view {
                        self.update(cornerRadius: view.cornerRadius)
                        self.updateShadowPath()
                    }
                }
            }
            get { return super.frame }
        }
        
        private unowned var _view: View?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
            self.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            guard let view = self._view else { return bounds }
            return QRect(bounds).apply(inset: view.textInset).cgRect
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            guard let view = self._view else { return bounds }
            return QRect(bounds).apply(inset: view.textInset).cgRect
        }

        override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            guard let view = self._view else { return bounds }
            let inset = view.placeholderInset ?? view.textInset
            return QRect(bounds).apply(inset: inset).cgRect
        }
        
    }
    
}

extension QInputStringView.InputStringView {
    
    func update(view: QInputStringView) {
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
        self.text = text
    }
    
    func update(textFont: QFont) {
        self.font = textFont.native
    }
    
    func update(textColor: QColor) {
        self.textColor = textColor.native
    }
    
    func update(textInset: QInset) {
        self.setNeedsLayout()
    }
    
    func update(editingColor: QColor) {
        self.tintColor = editingColor.native
    }
    
    func update(placeholder: QInputPlaceholder) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder.text, attributes: [
            .font: placeholder.font.native,
            .foregroundColor: placeholder.color.native
        ])
    }
    
    func update(placeholderInset: QInset?) {
        self.setNeedsLayout()
    }
    
    func update(alignment: QTextAlignment) {
        self.textAlignment = alignment.nsTextAlignment
    }
    
    func update(toolbar: IQInputToolbarView?) {
        self.inputAccessoryView = toolbar?.native
    }
    
    func update(keyboard: QInputKeyboard?) {
        self.keyboardType = keyboard?.type ?? .default
        self.keyboardAppearance = keyboard?.appearance ?? .default
        self.autocapitalizationType = keyboard?.autocapitalization ?? .sentences
        self.autocorrectionType = keyboard?.autocorrection ?? .default
        self.spellCheckingType = keyboard?.spellChecking ?? .default
        self.returnKeyType = keyboard?.returnKey ?? .default
        self.enablesReturnKeyAutomatically = keyboard?.enablesReturnKeyAutomatically ?? true
        if #available(iOS 10.0, *) {
            self.textContentType = keyboard?.textContent
        }
    }
    
    func cleanup() {
        self.customDelegate = nil
        self._view = nil
    }
    
}

extension QInputStringView.InputStringView : UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.customDelegate?.beginEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let sourceText = (textField.text ?? "") as NSString
        let newText = sourceText.replacingCharacters(in: range, with: string)
        self.customDelegate?.editing(text: newText)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.customDelegate?.endEditing()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.customDelegate?.pressedReturn()
        return true
    }

}

extension QInputStringView.InputStringView : IQReusable {
    
    typealias Owner = QInputStringView
    typealias Content = QInputStringView.InputStringView

    static var reuseIdentificator: String {
        return "QInputStringView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: .zero)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(content: Content) {
        content.cleanup()
    }
    
}

#endif
