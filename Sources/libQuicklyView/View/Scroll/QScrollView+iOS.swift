//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QScrollView {
    
    final class ScrollView : UIScrollView {
        
        unowned var customDelegate: ScrollViewDelegate?
        var needLayoutContent: Bool {
            didSet(oldValue) {
                if self.needLayoutContent == true {
                    self.setNeedsLayout()
                }
            }
        }
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
                if self.frame.size != oldValue.size {
                    self.needLayoutContent = true
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
        override var debugDescription: String {
            guard let view = self._view else { return super.debugDescription }
            return view.debugDescription
        }
        
        private unowned var _view: QScrollView?
        private var _contentView: UIView!
        private var _layoutManager: QLayoutManager!
        
        override init(frame: CGRect) {
            self.needLayoutContent = true
            
            super.init(frame: frame)

            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .never
            }
            self.clipsToBounds = true
            self.delegate = self
            
            self._contentView = UIView(frame: .zero)
            self.addSubview(self._contentView)
            
            self._layoutManager = QLayoutManager(contentView: self._contentView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func willMove(toSuperview superview: UIView?) {
            super.willMove(toSuperview: superview)
            
            if superview != nil {
                self.needLayoutContent = true
                self.setNeedsLayout()
            } else {
                self._layoutManager.clear()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if self.needLayoutContent == true {
                let frame = self.bounds
                if #available(iOS 11.0, *) {
                    let inset = self.adjustedContentInset
                    self._layoutManager.layout(
                        bounds: QRect(
                            x: 0,
                            y: 0,
                            width: QFloat(frame.width - (inset.left + inset.right)),
                            height: QFloat(frame.height - (inset.top + inset.bottom))
                        )
                    )
                } else {
                    self._layoutManager.layout(
                        bounds: QRect(
                            x: 0,
                            y: 0,
                            width: QFloat(frame.width),
                            height: QFloat(frame.height)
                        )
                    )
                }
                self.contentSize = self._layoutManager.size.cgSize
                self.customDelegate?.update(contentSize: self._layoutManager.size)
                self.needLayoutContent = false
            }
            self._layoutManager.visible(bounds: QRect(self.bounds))
        }
        
    }
        
}

extension QScrollView.ScrollView {
    
    func update(view: QScrollView) {
        self._view = view
        self.update(direction: view.direction)
        self.update(indicatorDirection: view.indicatorDirection)
        self.update(contentInset: view.contentInset)
        self.update(contentOffset: view.contentOffset, normalized: false)
        self.update(contentLayout: view.contentLayout)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
        self.customDelegate = view
    }
    
    func update(contentLayout: IQLayout) {
        if let contentLayout = self._layoutManager.layout {
            contentLayout.delegate = nil
        }
        if self.isAppeared == true {
            self._layoutManager.clear()
        }
        self._layoutManager.layout = contentLayout
        contentLayout.delegate = self
        if self.isAppeared == true {
            self.needLayoutContent = true
            self.setNeedsLayout()
        }
    }
    
    func update(direction: QScrollViewDirection) {
        self.alwaysBounceHorizontal = direction.contains(.horizontal)
        self.alwaysBounceVertical = direction.contains(.vertical)
        self.needLayoutContent = true
        self.setNeedsLayout()
    }
    
    func update(indicatorDirection: QScrollViewDirection) {
        self.showsHorizontalScrollIndicator = indicatorDirection.contains(.horizontal)
        self.showsVerticalScrollIndicator = indicatorDirection.contains(.vertical)
    }
    
    func update(contentInset: QInset) {
        self.contentInset = contentInset.uiEdgeInsets
    }
    
    func update(contentOffset: QPoint, normalized: Bool) {
        if normalized == true {
            let contentSize = self.contentSize
            let visibleSize = self.bounds.size
            self.contentOffset = CGPoint(
                x: max(0, min(CGFloat(contentOffset.x), contentSize.width - visibleSize.width)),
                y: max(0, min(CGFloat(contentOffset.y), contentSize.height - visibleSize.height))
            )
        } else {
            self.contentOffset = contentOffset.cgPoint
        }
    }
    
    func cleanup() {
        self.customDelegate = nil
        self._view = nil
    }
    
    func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint? {
        guard let item = view.item else { return nil }
        let contentSize = QSize(self.contentSize)
        let visibleSize = QSize(self.bounds.size)
        let itemFrame = item.frame
        let x: QFloat
        switch horizontal {
        case .leading: x = itemFrame.origin.x
        case .center: x = (itemFrame.origin.x + (itemFrame.size.width / 2)) - (visibleSize.width / 2)
        case .trailing: x = (itemFrame.origin.x + itemFrame.size.width) - visibleSize.width
        }
        let y: QFloat
        switch vertical {
        case .leading: y = itemFrame.origin.y
        case .center: y = (itemFrame.origin.y + (itemFrame.size.height / 2)) - (visibleSize.height / 2)
        case .trailing: y = (itemFrame.origin.y + itemFrame.size.height) - visibleSize.height
        }
        return QPoint(
            x: max(0, min(x, contentSize.width - visibleSize.width)),
            y: max(0, min(y, contentSize.height - visibleSize.height))
        )
    }
    
}

extension QScrollView.ScrollView : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.customDelegate?.beginScrolling()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.needLayoutContent == false {
            self.customDelegate?.scrolling(contentOffset: QPoint(scrollView.contentOffset))
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.customDelegate?.endScrolling(decelerate: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.customDelegate?.beginDecelerating()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.customDelegate?.endDecelerating()
    }
    
}

extension QScrollView.ScrollView : IQLayoutDelegate {
    
    func setNeedUpdate(_ parentLayout: IQLayout) {
        self.needLayoutContent = true
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ parentLayout: IQLayout) {
        self.layoutIfNeeded()
    }
    
}

extension QScrollView.ScrollView : IQReusable {
    
    typealias Owner = QScrollView
    typealias Content = QScrollView.ScrollView

    static var reuseIdentificator: String {
        return "QScrollView"
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
