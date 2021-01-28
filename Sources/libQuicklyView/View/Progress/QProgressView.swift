//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QProgressView : IQProgressView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.isAppeared
    }
    public private(set) var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var progressColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(progressColor: self.progressColor)
        }
    }
    public private(set) var trackColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(trackColor: self.trackColor)
        }
    }
    public private(set) var progress: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(progress: self.progress)
        }
    }
    public private(set) var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public private(set) var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public private(set) var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
        }
    }
    public private(set) var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
        }
    }
    public private(set) var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuseView: QReuseView< ProgressView >
    private var _view: ProgressView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        width: QDimensionBehaviour = .fill,
        height: QDimensionBehaviour,
        progressColor: QColor,
        trackColor: QColor,
        progress: QFloat,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        self.width = width
        self.height = height
        self.progressColor = progressColor
        self.trackColor = trackColor
        self.progress = progress
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuseView = QReuseView()
    }
    
    public func size(_ available: QSize) -> QSize {
        return available.apply(width: self.width, height: self.height)
    }
    
    public func appear(to layout: IQLayout) {
        self.parentLayout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
        self._onDisappear?()
    }
    
    @discardableResult
    public func width(_ value: QDimensionBehaviour) -> Self {
        self.width = value
        return self
    }
    
    @discardableResult
    public func height(_ value: QDimensionBehaviour) -> Self {
        self.height = value
        return self
    }
    
    @discardableResult
    public func progressColor(_ value: QColor) -> Self {
        self.progressColor = value
        return self
    }
    
    @discardableResult
    public func trackColor(_ value: QColor) -> Self {
        self.trackColor = value
        return self
    }
    
    @discardableResult
    public func progress(_ value: QFloat) -> Self {
        self.progress = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self.color = value
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self.border = value
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self.cornerRadius = value
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self.shadow = value
        return self
    }
    
    @discardableResult
    public func alpha(_ value: QFloat) -> Self {
        self.alpha = value
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._onAppear = value
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._onDisappear = value
        return self
    }
    
}
