//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QInputStringView {
    
    final class InputStringView : UITextField {
        
        weak var qDelegate: InputStringViewDelegate?
        var qText: String {
            set(value) { self.text = value }
            get { return self.text ?? "" }
        }
        var qFont: QFont {
            set(value) { self.font = value.native }
            get { return QFont(self.font!) }
        }
        var qColor: QColor {
            set(value) { self.textColor = value.native }
            get { return QColor(self.textColor!) }
        }
        var qInset: QInset? {
            didSet { self.setNeedsLayout() }
        }
        var qEditingColor: QColor {
            set(value) { self.tintColor = value.native }
            get { return QColor(self.tintColor!) }
        }
        var qPlaceholder: QInputPlaceholder? {
            didSet {
                if let placeholder = self.qPlaceholder {
                    self.attributedPlaceholder = NSAttributedString(string: placeholder.text, attributes: [
                        .font: placeholder.font.native,
                        .foregroundColor: placeholder.color.native
                    ])
                } else {
                    self.attributedPlaceholder = nil
                }
            }
        }
        var qPlaceholderInset: QInset? {
            didSet { self.setNeedsLayout() }
        }
        var qAlignment: QTextAlignment {
            set(value) { self.textAlignment = value.nsTextAlignment }
            get { return QTextAlignment(self.textAlignment) }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qToolbar: IQAccessoryView? {
            didSet {
                self.inputAccessoryView = self.qToolbar?.native
            }
        }
        var qKeyboard: QInputKeyboard {
            set(value) {
                self.keyboardType = value.type
                self.keyboardAppearance = value.appearance
                self.autocapitalizationType = value.autocapitalization
                self.autocorrectionType = value.autocorrection
                self.spellCheckingType = value.spellChecking
                self.returnKeyType = value.returnKey
                self.enablesReturnKeyAutomatically = value.enablesReturnKeyAutomatically
                if #available(iOS 10.0, *) {
                    self.textContentType = value.textContent
                }
            }
            get {
                if #available(iOS 10.0, *) {
                    return QInputKeyboard(
                        type: self.keyboardType,
                        appearance: self.keyboardAppearance,
                        autocapitalization: self.autocapitalizationType,
                        autocorrection: self.autocorrectionType,
                        spellChecking: self.spellCheckingType,
                        returnKey: self.returnKeyType,
                        enablesReturnKeyAutomatically: self.enablesReturnKeyAutomatically,
                        textContent: self.textContentType
                    )
                } else {
                    return QInputKeyboard(
                        type: self.keyboardType,
                        appearance: self.keyboardAppearance,
                        autocapitalization: self.autocapitalizationType,
                        autocorrection: self.autocorrectionType,
                        spellChecking: self.spellCheckingType,
                        returnKey: self.returnKeyType,
                        enablesReturnKeyAutomatically: self.enablesReturnKeyAutomatically
                    )
                }
            }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init() {
            super.init(frame: .zero)

            self.clipsToBounds = true
            self.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            let result = QRect(bounds)
            if let inset = self.qInset {
                return result.apply(inset: inset).cgRect
            }
            return result.cgRect
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            let result = QRect(bounds)
            if let inset = self.qInset {
                return result.apply(inset: inset).cgRect
            }
            return result.cgRect
        }

        override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            let result = QRect(bounds)
            if let inset = self.qPlaceholderInset {
                return result.apply(inset: inset).cgRect
            } else if let inset = self.qInset {
                return result.apply(inset: inset).cgRect
            }
            return result.cgRect
        }
        
    }
    
}

extension QInputStringView.InputStringView : UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.qDelegate?.beginEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let sourceText = (textField.text ?? "") as NSString
        let newText = sourceText.replacingCharacters(in: range, with: string)
        self.qDelegate?.editing(text: newText)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.qDelegate?.endEditing()
    }

}

extension QInputStringView.InputStringView : IQNativeBlendingView {
    
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

extension QInputStringView.InputStringView : IQReusable {
    
    typealias View = QInputStringView
    typealias Item = QInputStringView.InputStringView

    static var reuseIdentificator: String {
        return "QInputStringView"
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
