//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QScrollView {
    
    final class ScrollView : UIScrollView {
        
        weak var qDelegate: ScrollViewDelegate?
        var qDirection: Direction = [] {
            didSet(oldValue) {
                if self.qDirection != oldValue {
                    self.alwaysBounceHorizontal = self.qDirection.contains(.horizontal)
                    self.alwaysBounceVertical = self.qDirection.contains(.vertical)
                    self._contentView.needLayoutContent = true
                    self.setNeedsLayout()
                }
            }
        }
        var qLayout: IQDynamicLayout! {
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
                        self._contentView.needLayoutContent = true
                        self.setNeedsLayout()
                    }
                }
            }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qContentOffset: QPoint {
            set(value) { self.contentOffset = value.cgPoint }
            get { return QPoint(self.contentOffset) }
        }
        var qContentSize: QSize {
            get { return QSize(self.contentSize) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        override var frame: CGRect {
            didSet(oldValue) {
                if self.frame.size != oldValue.size {
                    self._contentView.needLayoutContent = true
                    self.setNeedsLayout()
                }
            }
        }
        override var contentSize: CGSize {
            set(value) {
                self._contentView.frame = CGRect(origin: CGPoint.zero, size: value)
                super.contentSize = value
                self.setNeedsLayout()
            }
            get { return super.contentSize }
        }
        
        private lazy var _contentView: ContentView = ContentView(owner: self)
        private var _visibleItems: [IQLayoutItem]

        init() {
            self._visibleItems = []
            
            super.init(frame: CGRect.zero)

            self.delegate = self
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .always
            }
            self.clipsToBounds = true
            
            self.addSubview(self._contentView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self._layoutContent(visibleRect: QRect(self.bounds))
        }
        
    }
    
    final class ContentView : UIView {
        
        weak var qOwner: ScrollView?
        var needLayoutContent: Bool {
            didSet(oldValue) {
                if self.needLayoutContent == true {
                    self.setNeedsLayout()
                }
            }
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
        override var frame: CGRect {
            didSet(oldValue) {
                guard self.frame != oldValue else { return }
                self.needLayoutContent = true
            }
        }

        init(owner: ScrollView) {
            self.qOwner = owner
            self.needLayoutContent = true
            
            super.init(frame: CGRect.zero)

            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didAddSubview(_ subview: UIView) {
            super.didAddSubview(subview)
            
            if let view = subview as? QNativeView {
                view.updateBlending(superview: self)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if self.needLayoutContent == true {
                self.qOwner?._layoutContent()
                self.needLayoutContent = false
            }
        }
        
    }
        
}

private extension QScrollView.ScrollView {
    
    func _appear(view: IQView) {
        guard view.isAppeared == false else { return }
        self._contentView.addSubview(view.native)
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
        self.qLayout.layout()
        self.contentSize = self.qLayout.size.cgSize
        self.qDelegate?.update(contentSize: self.qContentSize)
    }
    
    func _layoutContent(visibleRect: QRect) {
        let visibleItems = self.qLayout.items(bounds: visibleRect)
        let unvisibleItems = self._visibleItems.filter({ visibleItem in
            return visibleItems.contains(where: { return visibleItem === $0 }) == false
        })
        for item in unvisibleItems {
            self._disappear(view: item.view)
        }
        if self.qLayout.isValid == true {
            for item in visibleItems {
                if visibleRect.isIntersects(rect: item.frame) == true {
                    item.view.native.frame = item.frame.cgRect
                    self._appear(view: item.view)
                }
            }
            self._visibleItems = visibleItems
        } else {
            self._visibleItems = visibleItems
        }
    }
    
}

extension QScrollView.ScrollView : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.qDelegate?.beginScrolling()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self._contentView.needLayoutContent == false {
            self.qDelegate?.scrolling(contentOffset: self.qContentOffset)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.qDelegate?.endScrolling(decelerating: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.qDelegate?.beginDecelerating()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.qDelegate?.endDecelerating()
    }
    
}

extension QScrollView.ScrollView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.alpha < 1
    }
    
    func updateBlending(superview: QNativeView) {
        if self.allowBlending() == true || superview.allowBlending() == true {
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
        self.updateBlending()
    }
    
}

extension QScrollView.ContentView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.qOwner?.allowBlending() ?? false
    }
    
    func updateBlending(superview: QNativeView) {
        if self.allowBlending() == true || superview.allowBlending() == true {
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
        self.updateBlending()
    }
    
}

extension QScrollView.ScrollView : IQLayoutDelegate {
    
    func bounds(_ parentLayout: IQLayout) -> QRect {
        var result = QRect()
        let frame = self.bounds
        if #available(iOS 11.0, *) {
            let inset = self.adjustedContentInset
            if self.qDirection.contains(.vertical) == false {
                result.size.width = .infinity
            } else {
                result.size.width = QFloat(frame.width - (inset.left + inset.right))
            }
            if self.qDirection.contains(.horizontal) == false {
                result.size.height = .infinity
            } else {
                result.size.height = QFloat(frame.height - (inset.top + inset.bottom))
            }
        } else {
            if self.qDirection.contains(.vertical) == false {
                result.size.width = .infinity
            } else {
                result.size.width = QFloat(frame.width)
            }
            if self.qDirection.contains(.horizontal) == false {
                result.size.height = .infinity
            } else {
                result.size.height = QFloat(frame.height)
            }
        }
        return result
    }
    
    func setNeedUpdate(_ parentLayout: IQLayout) {
        self._contentView.needLayoutContent = true
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ parentLayout: IQLayout) {
        self.layoutIfNeeded()
    }
    
}

extension QScrollView.ScrollView : IQReusable {
    
    typealias View = QScrollView
    typealias Item = QScrollView.ScrollView

    static var reuseIdentificator: String {
        return "QScrollView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qDelegate = view
        item.qDirection = view.direction
        item.qLayout = view.layout
        item.qAlpha = view.alpha
        item.qContentOffset = view.contentOffset
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
