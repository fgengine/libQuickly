//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QScrollView {
    
    final class ScrollView : UIScrollView {
        
        typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
        
        unowned var customDelegate: ScrollViewDelegate?
        var needLayoutContent: Bool {
            didSet(oldValue) {
                if self.needLayoutContent == true {
                    self.setNeedsLayout()
                }
            }
        }
        override var frame: CGRect {
            set(value) {
                if super.frame != value {
                    let oldValue = value
                    super.frame = value
                    if let view = self._view {
                        self.update(cornerRadius: view.cornerRadius)
                        self.updateShadowPath()
                    }
                    if oldValue.size != value.size {
                        self.needLayoutContent = true
                        self.setNeedsLayout()
                    }
                }
            }
            get { return super.frame }
        }
        override var contentSize: CGSize {
            set(value) {
                if super.contentSize != value {
                    self._contentView.frame = CGRect(origin: CGPoint.zero, size: value)
                    super.contentSize = value
                    self.setNeedsLayout()
                }
            }
            get { return super.contentSize }
        }
        
        private unowned var _view: View?
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
            
            self._layoutManager = QLayoutManager(contentView: self._contentView, delegate: self)
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
                            width: Float(frame.width - (inset.left + inset.right)),
                            height: Float(frame.height - (inset.top + inset.bottom))
                        )
                    )
                } else {
                    self._layoutManager.layout(
                        bounds: QRect(
                            x: 0,
                            y: 0,
                            width: Float(frame.width),
                            height: Float(frame.height)
                        )
                    )
                }
                self.contentSize = self._layoutManager.size.cgSize
                self.customDelegate?._update(contentSize: self._layoutManager.size)
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
        self._layoutManager.layout = contentLayout
        self.needLayoutContent = true
        self.setNeedsLayout()
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
        self.scrollIndicatorInsets = contentInset.uiEdgeInsets
    }
    
    func update(contentOffset: QPoint, normalized: Bool) {
        let validContentOffset: CGPoint
        if normalized == true {
            let contentSize = self.contentSize
            let visibleSize = self.bounds.size
            validContentOffset = CGPoint(
                x: max(0, min(CGFloat(contentOffset.x), contentSize.width - visibleSize.width)),
                y: max(0, min(CGFloat(contentOffset.y), contentSize.height - visibleSize.height))
            )
        } else {
            validContentOffset = contentOffset.cgPoint
        }
        self.setContentOffset(validContentOffset, animated: false)
    }
    
    func cleanup() {
        self._layoutManager.layout = nil
        self.customDelegate = nil
        self._view = nil
    }
    
    func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint? {
        guard let item = view.item else { return nil }
        let contentSize = QSize(self.contentSize)
        let visibleSize = QSize(self.bounds.size)
        let itemFrame = item.frame
        let x: Float
        switch horizontal {
        case .leading: x = itemFrame.origin.x
        case .center: x = (itemFrame.origin.x + (itemFrame.size.width / 2)) - (visibleSize.width / 2)
        case .trailing: x = (itemFrame.origin.x + itemFrame.size.width) - visibleSize.width
        }
        let y: Float
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
        self.customDelegate?._beginScrolling()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.customDelegate?._scrolling(contentOffset: QPoint(scrollView.contentOffset))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.customDelegate?._endScrolling(decelerate: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.customDelegate?._beginDecelerating()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.customDelegate?._endDecelerating()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.customDelegate?._scrollToTop()
    }
    
}

extension QScrollView.ScrollView : IQLayoutDelegate {
    
    func setNeedUpdate(_ layout: IQLayout, force: Bool) {
        self.needLayoutContent = true
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
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
