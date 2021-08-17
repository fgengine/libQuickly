//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QScrollView {
    
    struct Reusable : IQReusable {
        
        typealias Owner = QScrollView
        typealias Content = NativeScrollView

        static var reuseIdentificator: String {
            return "QScrollView"
        }
        
        static func createReuse(owner: Owner) -> Content {
            return Content(frame: .zero)
        }
        
        static func configureReuse(owner: Owner, content: Content) {
            content.update(view: owner)
        }
        
        static func cleanupReuse(content: Content) {
            content.cleanup()
        }
        
    }
    
}

final class NativeScrollView : UIScrollView {
    
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
    private var _visibleInset: QInset {
        didSet(oldValue) {
            guard self._visibleInset != oldValue else { return }
            self.setNeedsLayout()
        }
    }
    private var _isLayout: Bool
    
    override init(frame: CGRect) {
        self.needLayoutContent = true
        self._visibleInset = .zero
        self._isLayout = false
        
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
        
        if superview == nil {
            self._layoutManager.clear()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self._safeLayout({
            let bounds = self.bounds
            if self.needLayoutContent == true {
                self.needLayoutContent = false
                
                let layoutBounds: QRect
                if #available(iOS 11.0, *) {
                    let inset = self.adjustedContentInset
                    layoutBounds = QRect(
                        x: 0,
                        y: 0,
                        width: Float(bounds.size.width - (inset.left + inset.right)),
                        height: Float(bounds.size.height - (inset.top + inset.bottom))
                    )
                } else {
                    layoutBounds = QRect(
                        x: 0,
                        y: 0,
                        width: Float(bounds.size.width),
                        height: Float(bounds.size.height)
                    )
                }
                self._layoutManager.layout(bounds: layoutBounds)
                let size = self._layoutManager.size
                self.contentSize = size.cgSize
                self.customDelegate?._update(contentSize: size)
            }
            self._layoutManager.visible(
                bounds: QRect(bounds),
                inset: self._visibleInset
            )
        })
    }
    
    @available(iOS 11.0, *)
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        self.scrollIndicatorInsets = self._scrollIndicatorInsets()
    }
    
}

extension NativeScrollView {
    
    func update< Layout : IQLayout >(view: QScrollView< Layout >) {
        self._view = view
        self.update(direction: view.direction)
        self.update(indicatorDirection: view.indicatorDirection)
        self.update(visibleInset: view.visibleInset)
        self.update(contentInset: view.contentInset)
        self.update(contentSize: view.contentSize)
        self.update(contentOffset: view.contentOffset, normalized: true)
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
    }
    
    func update(direction: QScrollViewDirection) {
        self.alwaysBounceHorizontal = direction.contains(.horizontal)
        self.alwaysBounceVertical = direction.contains(.vertical)
        self.needLayoutContent = true
    }
    
    func update(indicatorDirection: QScrollViewDirection) {
        self.showsHorizontalScrollIndicator = indicatorDirection.contains(.horizontal)
        self.showsVerticalScrollIndicator = indicatorDirection.contains(.vertical)
    }
    
    func update(visibleInset: QInset) {
        self._visibleInset = visibleInset
    }
    
    func update(contentInset: QInset) {
        self.contentInset = contentInset.uiEdgeInsets
        self.scrollIndicatorInsets = self._scrollIndicatorInsets()
    }
    
    func update(contentSize: QSize) {
        self.contentSize = contentSize.cgSize
    }
    
    func update(contentOffset: QPoint, normalized: Bool) {
        let validContentOffset: CGPoint
        if normalized == true {
            let contentInset = self.contentInset
            let contentSize = self.contentSize
            let visibleSize = self.bounds.size
            validContentOffset = CGPoint(
                x: max(-contentInset.left, min(-contentInset.left + CGFloat(contentOffset.x), contentSize.width - visibleSize.width + contentInset.right)),
                y: max(-contentInset.top, min(-contentInset.top + CGFloat(contentOffset.y), contentSize.height - visibleSize.height + contentInset.bottom))
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

private extension NativeScrollView {
    
    func _safeLayout(_ action: () -> Void) {
        if self._isLayout == false {
            self._isLayout = true
            action()
            self._isLayout = false
        }
    }
    
    func _scrollIndicatorInsets() -> UIEdgeInsets {
        let contentInset = self.contentInset
        let safeArea: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeArea = self.safeAreaInsets
        } else {
            safeArea = .zero
        }
        return UIEdgeInsets(
            top: contentInset.top - safeArea.top,
            left: contentInset.left - safeArea.left,
            bottom: contentInset.bottom - safeArea.bottom,
            right: contentInset.right - safeArea.right
        )
    }
    
}

extension NativeScrollView : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.customDelegate?._beginScrolling()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.customDelegate?._scrolling(contentOffset: QPoint(scrollView.contentOffset))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.customDelegate?._endScrolling(decelerate: decelerate)
        if decelerate == false {
            self.setNeedsLayout()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.customDelegate?._beginDecelerating()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.customDelegate?._endDecelerating()
        self.setNeedsLayout()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.customDelegate?._scrollToTop()
    }
    
}

extension NativeScrollView : IQLayoutDelegate {
    
    func setNeedUpdate(_ layout: IQLayout) -> Bool {
        self.needLayoutContent = true
        self.setNeedsLayout()
        return false
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
        self.layoutIfNeeded()
    }
    
}

#endif
