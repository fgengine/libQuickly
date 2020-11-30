//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QControlView {
    
    final class ControlView : UIControl {
        
        unowned var qDelegate: CustomViewDelegate!
        var qLayout: IQLayout! {
            willSet(newValue) {
                if self.qLayout !== newValue {
                    if let layout = self.qLayout {
                        layout.delegate = nil
                    }
                    if self.superview != nil {
                        self._disappear()
                    }
                }
            }
            didSet(oldValue) {
                if self.qLayout !== oldValue {
                    if let layout = self.qLayout {
                        layout.delegate = self
                    }
                    if self.superview != nil {
                        self.setNeedsLayout()
                    }
                }
            }
        }
        var qIsOpaque: Bool = true {
            didSet(oldValue) { self.isOpaque = self.qIsOpaque }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        var qShouldHighlighting: Bool {
            return self.qDelegate.shouldHighlighting(view: self)
        }
        var qShouldPressing: Bool {
            return self.qDelegate.shouldPressing(view: self)
        }
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
        
        private var _visibleItems: [IQLayoutItem]
        
        init() {
            self._visibleItems = []
            
            super.init(frame: .zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.clipsToBounds = true
            
            self.addTarget(self, action: #selector(self._touchDown(_:)), for: .touchDown)
            self.addTarget(self, action: #selector(self._touchDragEnter(_:)), for: .touchDragEnter)
            self.addTarget(self, action: #selector(self._touchDragExit(_:)), for: .touchDragExit)
            self.addTarget(self, action: #selector(self._touchUpInside(_:)), for: .touchUpInside)
            self.addTarget(self, action: #selector(self._touchUpOutside(_:)), for: .touchUpOutside)
            self.addTarget(self, action: #selector(self._touchUpOutside(_:)), for: .touchCancel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toSuperview superview: UIView?) {
            super.willMove(toSuperview: superview)
            
            if superview == nil {
                self._disappear()
            }
        }
        
        override func didAddSubview(_ subview: UIView) {
            super.didAddSubview(subview)
            
            if let view = subview as? QNativeView {
                view.updateBlending(superview: self)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self._layoutContent()
            self._layoutContent(visibleRect: QRect(self.bounds))
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if self.qShouldHighlighting == true || self.qShouldPressing == true {
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

private extension QControlView.ControlView {
    
    func _appear(view: IQView) {
        guard view.isAppeared == false else { return }
        self.addSubview(view.native)
        view.onAppear(to: self.qLayout)
    }
    
    func _disappear(view: IQView) {
        guard view.isAppeared == true else { return }
        view.native.removeFromSuperview()
        view.onDisappear()
    }
    
    func _disappear() {
        for item in self.qLayout.items {
            if item.view.isAppeared == false { continue }
            item.view.native.removeFromSuperview()
            item.view.onDisappear()
        }
    }
    
    func _layoutContent() {
        let frame = QRect(self.frame)
        self.qLayout.layout()
        if self.qLayout.size != frame.size {
            self.qLayout.parentView?.parentLayout?.setNeedUpdate()
        }
    }
    
    func _layoutContent(visibleRect: QRect) {
        let visibleItems = self.qLayout.items(bounds: visibleRect)
        let unvisibleItems = self._visibleItems.filter({ visibleItem in
            return visibleItems.contains(where: { return visibleItem === $0 }) == false
        })
        for item in unvisibleItems {
            self._disappear(view: item.view)
        }
        for item in visibleItems {
            if visibleRect.isIntersects(rect: item.frame) == true {
                item.view.native.frame = item.frame.cgRect
                self._appear(view: item.view)
            }
        }
        self._visibleItems = visibleItems
    }
    
    @objc
    func _touchDown(_ sender: Any) {
        if self.qShouldHighlighting == true {
            self.qDelegate.set(view: self, highlighted: true, userIteraction: true)
        }
    }
    
    @objc
    func _touchDragEnter(_ sender: Any) {
        if self.qShouldHighlighting == true {
            self.qDelegate.set(view: self, highlighted: true, userIteraction: true)
        }
    }
    
    @objc
    func _touchDragExit(_ sender: Any) {
        if self.qShouldHighlighting == true {
            self.qDelegate.set(view: self, highlighted: false, userIteraction: true)
        }
    }
    
    @objc
    func _touchUpInside(_ sender: Any) {
        if self.qShouldPressing == true {
            self.qDelegate.pressed(view: self)
        }
        if self.qShouldHighlighting == true {
            self.qDelegate.set(view: self, highlighted: false, userIteraction: true)
        }
    }
    
    @objc
    func _touchUpOutside(_ sender: Any) {
        if self.qShouldHighlighting == true {
            self.qDelegate.set(view: self, highlighted: false, userIteraction: true)
        }
    }
    
}

extension QControlView.ControlView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.qIsOpaque == false || self.alpha < 1
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

extension QControlView.ControlView : IQLayoutDelegate {
    
    func bounds(_ parentLayout: IQLayout) -> QRect {
        return QRect(self.bounds)
    }
    
    func setNeedUpdate(_ parentLayout: IQLayout) {
        self.qLayout.parentView?.parentLayout?.setNeedUpdate()
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ parentLayout: IQLayout) {
        self.qLayout.parentView?.parentLayout?.updateIfNeeded()
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
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qLayout = view.layout
        item.qIsOpaque = view.isOpaque
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
