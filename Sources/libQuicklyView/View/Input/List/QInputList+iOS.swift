//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QInputListView {
    
    final class InputListView : UITextField {
        
        weak var qDelegate: InputListViewDelegate?
        var qItems: [QInputListView.Item] {
            didSet {
                self._picker.reloadAllComponents()
            }
        }
        var qSelectedItem: QInputListView.Item? {
            didSet {
                if let item = self.qSelectedItem {
                    self.text = item.title
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
        
        private var _picker: UIPickerView
        
        init() {
            self.qItems = []
            self._picker = UIPickerView()
            
            super.init(frame: .zero)
            
            self.delegate = self
            self.clipsToBounds = true
            self.inputView = self._picker
            
            self._picker.dataSource = self
            self._picker.delegate = self
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

extension QInputListView.InputListView : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.qDelegate?.beginEditing()
        if self.qSelectedItem == nil {
            if let firstItem = self.qItems.first {
                self.qSelectedItem = firstItem
                self.qDelegate?.select(item: firstItem)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.qDelegate?.endEditing()
    }
    
}

extension QInputListView.InputListView : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.qItems.count
    }
    
}

extension QInputListView.InputListView : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.qItems[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = self.qItems[row]
        if self.qSelectedItem !== selectedItem {
            self.qSelectedItem = selectedItem
            self.qDelegate?.select(item: selectedItem)
        }
    }
    
}

extension QInputListView.InputListView : IQNativeBlendingView {
    
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

extension QInputListView.InputListView : IQReusable {
    
    typealias View = QInputListView
    typealias Item = QInputListView.InputListView

    static var reuseIdentificator: String {
        return "QInputListView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qItems = view.items
        item.qSelectedItem = view.selectedItem
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

#endif
