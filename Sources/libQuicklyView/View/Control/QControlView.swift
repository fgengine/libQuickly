//
//  libQuicklyView
//

import Foundation

protocol CustomViewDelegate : AnyObject {
    
    func shouldHighlighting(view: QControlView.ControlView) -> Bool
    func set(view: QControlView.ControlView, highlighted: Bool, userIteraction: Bool)
    
    func shouldPressing(view: QControlView.ControlView) -> Bool
    func pressed(view: QControlView.ControlView)
    
}

open class QControlView : IQView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var layout: IQDynamicLayout {
        willSet {
            self.layout.parentView = nil
        }
        didSet(oldValue) {
            self.layout.parentView = self
            guard self.isLoaded == true else { return }
            self._view.qLayout = self.layout
        }
    }
    public var shouldHighlighting: Bool {
        didSet {
            if self.shouldHighlighting == false {
                self.isHighlighted = false
            }
        }
    }
    public var isHighlighted: Bool {
        set(value) {
            if self._isHighlighted != value {
                self._isHighlighted = value
                self.didChange(highlighted: self._isHighlighted, userIteraction: false)
            }
        }
        get { return self._isHighlighted }
    }
    public var shouldPressed: Bool
    public var isOpaque: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qIsOpaque = self.isOpaque
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.qIsAppeared
    }
    public var native: QNativeView {
        return self._view
    }

    private var _isHighlighted: Bool
    private var _view: ControlView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< ControlView >
    
    public init(
        layout: IQDynamicLayout,
        shouldHighlighting: Bool = false,
        isHighlighted: Bool = false,
        shouldPressed: Bool = false,
        isOpaque: Bool = true,
        alpha: QFloat = 1
    ) {
        self.layout = layout
        self.shouldHighlighting = shouldHighlighting
        self._isHighlighted = shouldHighlighting == true && isHighlighted == true
        self.shouldPressed = shouldPressed
        self.isOpaque = isOpaque
        self.alpha = alpha
        self._reuseView = QReuseView()
        self.layout.parentView = self
    }
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return self.layout.size(available)
    }
    
    open func didChange(highlighted: Bool, userIteraction: Bool) {
    }
    
    open func didPressed() {
    }
    
}

extension QControlView : CustomViewDelegate {
    
    func shouldHighlighting(view: QControlView.ControlView) -> Bool {
        return self.shouldHighlighting
    }
    
    func set(view: QControlView.ControlView, highlighted: Bool, userIteraction: Bool) {
        if self._isHighlighted != highlighted {
            self._isHighlighted = highlighted
            self.didChange(highlighted: self._isHighlighted, userIteraction: true)
        }
    }
    
    func shouldPressing(view: QControlView.ControlView) -> Bool {
        return self.shouldPressed
    }
    
    func pressed(view: QControlView.ControlView) {
        self.didPressed()
    }
    
}
