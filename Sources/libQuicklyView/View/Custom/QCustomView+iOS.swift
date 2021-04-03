//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QCustomView {
    
    final class CustomView : UIView {
        
        unowned var customDelegate: CustomViewDelegate!
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
        override var debugDescription: String {
            guard let view = self._view else { return super.debugDescription }
            return view.debugDescription
        }
        
        private unowned var _view: QCustomView?
        private var _layoutManager: QLayoutManager!
        private var _gestures: [IQGesture]
        
        override init(frame: CGRect) {
            self._gestures = []
            
            super.init(frame: frame)
            
            self.clipsToBounds = true
            
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
            if self.customDelegate.shouldHighlighting(view: self) == true || self._gestures.count > 0 {
                return super.hitTest(point, with: event)
            }
            if let hitView = super.hitTest(point, with: event) {
                if hitView != self {
                    return hitView
                }
            }
            return nil
        }
        
        override func touchesBegan(_ touches: Set< UITouch >, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: true)
            }
        }
        
        override func touchesEnded(_ touches: Set< UITouch >, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: false)
            }
        }
        
        override func touchesCancelled(_ touches: Set< UITouch >, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: false)
            }
        }
        
    }

}

extension QCustomView.CustomView {
    
    func update(view: QCustomView) {
        self._view = view
        self.update(gestures: view.gestures)
        self.update(layout: view.layout)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
        self.customDelegate = view
    }
    
    func update(gestures: [IQGesture]) {
        for gesture in self._gestures {
            self.removeGestureRecognizer(gesture.native)
        }
        self._gestures = gestures
        for gesture in self._gestures {
            self.addGestureRecognizer(gesture.native)
        }
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
    
    func cleanup() {
        self.customDelegate = nil
        self._view = nil
    }
    
    func add(gesture: IQGesture) {
        if self._gestures.contains(where: { $0 === gesture }) == false {
            self._gestures.append(gesture)
        }
        self.addGestureRecognizer(gesture.native)
    }
    
    func remove(gesture: IQGesture) {
        if let index = self._gestures.firstIndex(where: { $0 === gesture }) {
            self._gestures.remove(at: index)
        }
        self.removeGestureRecognizer(gesture.native)
    }
    
}

extension QCustomView.CustomView : IQLayoutDelegate {
    
    func setNeedUpdate(_ parentLayout: IQLayout) {
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ parentLayout: IQLayout) {
        self._layoutManager.layout?.parentView?.parentLayout?.updateIfNeeded()
        self.layoutIfNeeded()
    }
    
}

extension QCustomView.CustomView : IQReusable {
    
    typealias Owner = QCustomView
    typealias Content = QCustomView.CustomView

    static var reuseIdentificator: String {
        return "QCustomView"
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
