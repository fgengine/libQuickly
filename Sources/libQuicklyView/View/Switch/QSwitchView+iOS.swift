//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QSwitchView {
    
    final class SwitchView : UIView {
        
        weak var qDelegate: SwitchViewDelegate?
        var qThumbColor: QColor {
            set(value) { self._switch.thumbTintColor = value.native }
            get { return QColor(self._switch.thumbTintColor!) }
        }
        var qOffColor: QColor {
            set(value) { self._switch.tintColor = value.native }
            get { return QColor(self._switch.tintColor!) }
        }
        var qOnColor: QColor {
            set(value) { self._switch.onTintColor = value.native }
            get { return QColor(self._switch.onTintColor!) }
        }
        var qValue: Bool {
            set(value) { self._switch.isOn = value }
            get { return self._switch.isOn }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _switch: UISwitch!
        
        init() {
            super.init(frame: .zero)
            
            self.clipsToBounds = true
            
            self._switch = UISwitch()
            self._switch.addTarget(self, action: #selector(self._changed(_:)), for: .valueChanged)
            self.addSubview(self._switch)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            let switchSize = self._switch.sizeThatFits(bounds.size)
            self._switch.frame = CGRect(
                x: bounds.midX - (switchSize.width / 2),
                y: bounds.midY - (switchSize.height / 2),
                width: switchSize.width,
                height: switchSize.height
            )
        }
        
    }
    
}

private extension QSwitchView.SwitchView {
    
    @objc
    func _changed(_ sender: Any) {
        self.qDelegate?.changed(value: self._switch.isOn)
    }
    
}

extension QSwitchView.SwitchView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.alpha < 1
    }
    
    func updateBlending(superview: QNativeView) {
        if self.allowBlending() == true || superview.allowBlending() == true {
            self._switch.backgroundColor = .clear
            self._switch.isOpaque = false
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self._switch.backgroundColor = superview.backgroundColor
            self._switch.isOpaque = true
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
    }
    
}

extension QSwitchView.SwitchView : IQReusable {
    
    typealias View = QSwitchView
    typealias Item = QSwitchView.SwitchView

    static var reuseIdentificator: String {
        return "QSwitchView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qThumbColor = view.thumbColor
        item.qOffColor = view.offColor
        item.qOnColor = view.onColor
        item.qValue = view.value
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
