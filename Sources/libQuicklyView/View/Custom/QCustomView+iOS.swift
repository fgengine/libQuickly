//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QCustomView {
    
    final class LayoutView : UIView {
        
        var qGestures: [IQGesture] {
            willSet {
                for gesture in self.qGestures {
                    self.removeGestureRecognizer(gesture.native)
                }
            }
            didSet {
                for gesture in self.qGestures {
                    self.addGestureRecognizer(gesture.native)
                }
            }
        }
        var qLayout: IQLayout! {
            willSet(newValue) {
                if self.qLayout !== newValue {
                    if let layout = self.qLayout {
                        layout.delegate = nil
                    }
                    self._disappear()
                }
            }
            didSet(oldValue) {
                if self.qLayout !== oldValue {
                    if let layout = self.qLayout {
                        layout.delegate = self
                    }
                    self.setNeedsLayout()
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
            self.qGestures = []
            self._visibleItems = []
            
            super.init(frame: .zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toSuperview superview: UIView?) {
            super.willMove(toSuperview: superview)
            
            if superview != nil {
                self.setNeedsLayout()
            } else {
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
            if let hitView = super.hitTest(point, with: event) {
                if hitView != self {
                    return hitView
                }
            }
            return nil
        }
        
    }

}

private extension QCustomView.LayoutView {
    
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
        for item in self._visibleItems {
            self._disappear(view: item.view)
        }
        self._visibleItems.removeAll()
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
    
}

extension QCustomView.LayoutView : IQNativeBlendingView {
    
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

extension QCustomView.LayoutView : IQLayoutDelegate {
    
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

extension QCustomView.LayoutView : IQReusable {
    
    typealias View = QCustomView
    typealias Item = QCustomView.LayoutView

    static var reuseIdentificator: String {
        return "QCustomView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qGestures = view.gestures
        item.qLayout = view.layout
        item.qIsOpaque = view.isOpaque
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
