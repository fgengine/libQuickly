//
//  libQuicklyView
//

#if os(OSX)

import AppKit
import libQuicklyCore

extension QScrollView {
    
    final class ScrollView : NSScrollView {
        
        weak var qDelegate: ScrollViewDelegate?
        var qDirection: Direction = [] {
            didSet(oldValue) {
                if self.qDirection != oldValue {
                    self.hasHorizontalScroller = self.qDirection.contains(.horizontal)
                    self.hasVerticalScroller = self.qDirection.contains(.vertical)
                    self._documentView.needsLayout = true
                    self._contentView.needsLayout = true
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
                    self._documentView.needsLayout = true
                    self._contentView.needsLayout = true
                }
            }
        }
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qContentOffset: QPoint {
            set(value) { self.scroll(value.cgPoint) }
            get { return QPoint(self._contentView.documentRect.origin) }
        }
        var qContentSize: QSize {
            get { return QSize(self._documentView.frame.size) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        override var frame: CGRect {
            didSet(oldValue) {
                if self.frame.size != oldValue.size {
                    self._documentView.needsLayout = true
                    self._contentView.needsLayout = true
                }
            }
        }
        override var isFlipped: Bool {
            return true
        }
        
        private lazy var _contentView: ContentView = {
            let view = ContentView(owner: self)
            return view
        }()
        private lazy var _documentView: DocumentView = {
            let view = DocumentView(owner: self)
            return view
        }()
        private var _visibleItems: [IQLayoutItem]

        init() {
            self._visibleItems = []
            
            super.init(frame: CGRect.zero)
            
            self.autohidesScrollers = true
            self.contentView = self._contentView
            self.documentView = self._documentView
            
            NotificationCenter.default.addObserver(self, selector: #selector(self._startScrolling(_:)), name: Self.willStartLiveScrollNotification, object: self)
            NotificationCenter.default.addObserver(self, selector: #selector(self._scrolling(_:)), name: Self.didLiveScrollNotification, object: self)
            NotificationCenter.default.addObserver(self, selector: #selector(self._endScrolling(_:)), name: Self.didEndLiveScrollNotification, object: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            self.documentView = nil
        }

        override func viewWillMove(toSuperview superview: NSView?) {
            super.viewWillMove(toSuperview: superview)

            if superview != nil {
                self.needsLayout = true
            } else {
                self._disappear()
            }
        }
        
        func layoutContent() {
            self.qLayout.layout()
            self._documentView.frame = NSRect(
                origin: self.frame.origin,
                size: self.qLayout.size.cgSize
            )
            self.qDelegate?.update(contentSize: self.qContentSize)
        }
        
        func layoutContent(visibleRect: QRect) {
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
            }
        }
        
    }
    
    final class ContentView : NSClipView {
        
        weak var qOwner: ScrollView?
        override var isFlipped: Bool {
            return true
        }

        init(owner: ScrollView) {
            self.qOwner = owner
            
            super.init(frame: CGRect.zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            super.layout()
            self.qOwner?.layoutContent(visibleRect: QRect(self.documentVisibleRect).apply(inset: self.contentInsets))
        }
        
        override func scroll(to newOrigin: NSPoint) {
            super.scroll(to: newOrigin)
            self.qOwner?.layoutContent(visibleRect: QRect(
                topLeft: QPoint(newOrigin),
                size: QSize(self.documentVisibleRect.size)
            ).apply(inset: self.contentInsets))
        }
        
    }
    
    final class DocumentView : NSView {
        
        weak var qOwner: ScrollView?
        override var isFlipped: Bool {
            return true
        }

        init(owner: ScrollView) {
            self.qOwner = owner
            
            super.init(frame: CGRect.zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            super.layout()
            self.qOwner?.layoutContent()
        }
        
    }
        
}

private extension QScrollView.ScrollView {
    
    func _appear(view: IQView) {
        guard view.isAppeared == false else { return }
        self._documentView.addSubview(view.native)
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
    
    @objc
    func _startScrolling(_ sender: Any) {
        self.qDelegate?.beginScrolling()
    }
    
    @objc
    func _scrolling(_ sender: Any) {
        self.qDelegate?.scrolling(contentOffset: QPoint(self._contentView.documentRect.origin))
    }
    
    @objc
    func _endScrolling(_ sender: Any) {
        self.qDelegate?.endScrolling(decelerating: false)
    }
    
}

extension QScrollView.ScrollView : IQLayoutDelegate {
    
    func bounds(_ layout: IQLayout) -> QRect {
        var bounds = QRect(self.bounds)
        if self.qDirection.contains(.horizontal) == false {
            bounds.size.height = .infinity
        }
        if self.qDirection.contains(.vertical) == false {
            bounds.size.width = .infinity
        }
        return bounds
    }
    
    func setNeedUpdate(_ layout: IQLayout) {
        self._documentView.needsLayout = true
        self._contentView.needsLayout = true
        self.needsLayout = true
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
        self.layoutSubtreeIfNeeded()
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
