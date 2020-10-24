//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QInputDateView {
    
    final class InputDateView : UITextField {
        
        weak var qDelegate: InputDateViewDelegate?
        var qMode: QInputDateView.Mode {
            didSet {
                self._picker.datePickerMode = self.qMode.datePickerMode
            }
        }
        var qMinimumDate: Date? {
            didSet { self._picker.minimumDate = self.qMinimumDate }
        }
        var qMaximumDate: Date? {
            didSet { self._picker.maximumDate = self.qMaximumDate }
        }
        var qSelectedDate: Date? {
            didSet {
                if let formatter = self.qFormatter, let selectedDate = self.qSelectedDate {
                    self.text = formatter.text(selectedDate)
                    self._picker.date = selectedDate
                } else {
                    self.text = ""
                }
            }
        }
        var qFormatter: IQInputDateFormatter? {
            didSet {
                if let formatter = self.qFormatter, let selectedDate = self.qSelectedDate {
                    self.text = formatter.text(selectedDate)
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
        var qToolbar: IQAccessoryView? {
            didSet {
                self.inputAccessoryView = self.qToolbar?.native
            }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _picker: UIDatePicker
        
        init(mode: QInputDateView.Mode) {
            self.qMode = mode

            self._picker = UIDatePicker()
            self._picker.datePickerMode = self.qMode.datePickerMode
            if #available(iOS 13.4, *) {
                self._picker.preferredDatePickerStyle = .wheels
            }
            
            super.init(frame: .zero)
            
            self.delegate = self
            self.clipsToBounds = true
            self.inputView = self._picker
            
            self._picker.addTarget(self, action: #selector(self._changed(_:)), for: .valueChanged)
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

extension QInputDateView.InputDateView {
    
    @objc
    private func _changed(_ sender: UIDatePicker) {
        self.qSelectedDate = sender.date
        self.qDelegate?.select(date: sender.date)
    }
    
}

extension QInputDateView.InputDateView : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.qDelegate?.beginEditing()
        if self.qSelectedDate == nil {
            self.qSelectedDate = self._picker.date
            self.qDelegate?.select(date: self._picker.date)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.qDelegate?.endEditing()
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
        return Item(mode: view.mode)
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qMode = view.mode
        item.qMinimumDate = view.minimumDate
        item.qMaximumDate = view.maximumDate
        item.qSelectedDate = view.selectedDate
        item.qFormatter = view.formatter
        item.qFont = view.font
        item.qColor = view.color
        item.qInset = view.inset
        item.qPlaceholder = view.placeholder
        item.qPlaceholderInset = view.placeholderInset
        item.qAlignment = view.alignment
        item.qAlpha = view.alpha
        item.qToolbar = view.toolbar
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

extension QInputDateView.Mode {
    
    var datePickerMode: UIDatePicker.Mode {
        switch self {
        case .time: return .time
        case .date: return .date
        case .dateTime: return .dateAndTime
        }
    }
    
}

#endif
