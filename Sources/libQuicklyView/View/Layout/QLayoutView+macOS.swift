//
//  libQuicklyView
//

#if os(OSX)

import AppKit

extension QLayoutView {
    
    final class LayoutView : NSView {
        
        var qLayout: IQDynamicLayout! {
            willSet(newValue) {
                if self.qLayout !== newValue {
                    if let content = self.qLayout {
                        content.delegate = nil
                    }
                    if self.superview != nil {
                        self._disappear()
                    }
                }
            }
            didSet(oldValue) {
                if self.qLayout !== oldValue {
                    if let content = self.qLayout {
                        content.delegate = self
                    }
                    if self.superview != nil {
                        self.needsLayout = true
                    }
                }
            }
        }
        var qIsOpaque: Bool = true
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        override var isOpaque: Bool {
            return self.qIsOpaque
        }
        override var isFlipped: Bool {
            return true
        }
        
        private var _visibleItems: [IQLayoutItem]
        
        init() {
            self._visibleItems = []
            
            super.init(frame: .zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillMove(toSuperview newSuperview: NSView?) {
            super.viewWillMove(toSuperview: newSuperview)
            
            if superview == nil {
                self._disappear()
            }
        }
        
        override func layout() {
            super.layout()
            
            self._layoutContent()
            self._layoutContent(visibleRect: QRect(self.bounds))
        }
        
        override func hitTest(_ point: NSPoint) -> NSView? {
            if let hitView = super.hitTest(point) {
                if hitView != self {
                    return hitView
                }
            }
            return nil
        }
        
    }
        
}

private extension QLayoutView.LayoutView {
    
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
    
}

extension QLayoutView.LayoutView : IQLayoutDelegate {
    
    func bounds(_ layout: IQLayout) -> QRect {
        return QRect(self.bounds)
    }
    
    func setNeedUpdate(_ layout: IQLayout) {
        self.qLayout.parentView?.parentLayout?.setNeedUpdate()
        self.needsLayout = true
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
        self.qLayout.parentView?.parentLayout?.updateIfNeeded()
        self.layoutSubtreeIfNeeded()
    }
    
}

extension QLayoutView.LayoutView : IQReusable {
    
    typealias View = QLayoutView
    typealias Item = QLayoutView.LayoutView

    static var reuseIdentificator: String {
        return "QLayoutView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qLayout = view.layout
        item.qIsOpaque = view.isOpaque
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif