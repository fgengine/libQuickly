//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QInputDateView {
    
    final class InputDateView : UITextField {
        
        var qSelectedDate: Date? {
            didSet {
                if let date = self.qSelectedDate {
                    self._picker.date = date
                } else {
                    self.text = ""
                }
            }
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
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _picker: UIDatePicker
        
        init() {
            self._picker = UIDatePicker()
            if #available(iOS 13.4, *) {
                self._picker.preferredDatePickerStyle = .wheels
            }
            
            super.init(frame: .zero)
            
            self.delegate = self
            self.clipsToBounds = true
            self.inputView = self._picker
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

extension QInputDateView.InputDateView : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.qSelectedDate == nil {
            self.qSelectedDate = self._picker.date
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
}

extension QInputDateView.InputDateView : IQNativeBlendingView {
    
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

extension QInputDateView.InputDateView : IQReusable {
    
    typealias View = QInputDateView
    typealias Item = QInputDateView.InputDateView

    static var reuseIdentificator: String {
        return "QInputDateView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qSelectedDate = view.selectedDate
        item.qFont = view.font
        item.qColor = view.color
        item.qInset = view.inset
        item.qPlaceholder = view.placeholder
        item.qPlaceholderInset = view.placeholderInset
        item.qAlignment = view.alignment
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
