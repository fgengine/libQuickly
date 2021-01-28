//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QControlView {
    
    final class ControlView : UIControl {
        
        unowned var customDelegate: ControlViewDelegate!
        var contentSize: QSize {
            return self._layoutManager.size
        }
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        
        private unowned var _view: QControlView?
        private var _layoutManager: QLayoutManager!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
            
            self.addTarget(self, action: #selector(self._touchDown(_:)), for: .touchDown)
            self.addTarget(self, action: #selector(self._touchDragEnter(_:)), for: .touchDragEnter)
            self.addTarget(self, action: #selector(self._touchDragExit(_:)), for: .touchDragExit)
            self.addTarget(self, action: #selector(self._touchUpInside(_:)), for: .touchUpInside)
            self.addTarget(self, action: #selector(self._touchUpOutside(_:)), for: .touchUpOutside)
            self.addTarget(self, action: #selector(self._touchUpOutside(_:)), for: .touchCancel)
            
            self._layoutManager = QLayoutManager(contentView: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toSuperview superview: UIView?) {
            super.willMove(toSuperview: superview)
            
            if superview != nil {
                self.setNeedsLayout()
            } else {
                self._layoutManager.clear()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let frame = QRect(self.frame)
            self._layoutManager.layout(bounds: QRect(self.bounds))
            if self._layoutManager.size != frame.size {
                self._layoutManager.setNeedUpdate(true)
            }
            self._layoutManager.visible(bounds: QRect(self.bounds))
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if self.customDelegate.shouldHighlighting(view: self) == true || self.customDelegate.shouldPressing(view: self) == true {
                return super.hitTest(point, with: event)
            }
            if let hitView = super.hitTest(point, with: event) {
                if hitView != self {
                    return hitView
                }
            }
            return nil
        }
        
    }

}

extension QControlView.ControlView {
    
    func update(view: QControlView) {
        self._view = view
        self.update(layout: view.layout)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(layout: IQLayout) {
        if let layout = self._layoutManager.layout {
            layout.delegate = nil
        }
        if self.isAppeared == true {
            self._layoutManager.clear()
        }
        self._layoutManager.layout = layout
        layout.delegate = self
        if self.isAppeared == true {
            self.setNeedsLayout()
        }
    }
    
}

private extension QControlView.ControlView {
    
    @objc
    func _touchDown(_ sender: Any) {
        if self.customDelegate.shouldHighlighting(view: self) == true {
            self.customDelegate.set(view: self, highlighted: true)
        }
    }
    
    @objc
    func _touchDragEnter(_ sender: Any) {
        if self.customDelegate.shouldHighlighting(view: self) == true {
            self.customDelegate.set(view: self, highlighted: true)
        }
    }
    
    @objc
    func _touchDragExit(_ sender: Any) {
        if self.customDelegate.shouldHighlighting(view: self) == true {
            self.customDelegate.set(view: self, highlighted: false)
        }
    }
    
    @objc
    func _touchUpInside(_ sender: Any) {
        if self.customDelegate.shouldPressing(view: self) == true {
            self.customDelegate.pressed(view: self)
        }
        if self.customDelegate.shouldHighlighting(view: self) == true {
            self.customDelegate.set(view: self, highlighted: false)
        }
    }
    
    @objc
    func _touchUpOutside(_ sender: Any) {
        if self.customDelegate.shouldHighlighting(view: self) == true {
            self.customDelegate.set(view: self, highlighted: false)
        }
    }
    
}

extension QControlView.ControlView : IQLayoutDelegate {
    
    func setNeedUpdate(_ parentLayout: IQLayout) {
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ parentLayout: IQLayout) {
        self._layoutManager.layout?.parentView?.parentLayout?.updateIfNeeded()
        self.layoutIfNeeded()
    }
    
}

extension QControlView.ControlView : IQReusable {
    
    typealias View = QControlView
    typealias Item = QControlView.ControlView

    static var reuseIdentificator: String {
        return "QControlView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item(frame: .zero)
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.update(view: view)
        item.customDelegate = view
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
        item.customDelegate = nil
    }
    
}

#endif
