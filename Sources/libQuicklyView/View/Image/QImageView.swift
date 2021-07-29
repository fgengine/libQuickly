//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QImageView : IQImageView {
    
    public private(set) unowned var layout: IQLayout?
    public unowned var item: QLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuse.isLoaded
    }
    public var bounds: QRect {
        guard self.isLoaded == true else { return .zero }
        return QRect(self._view.bounds)
    }
    public var width: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public var height: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public var image: QImage {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(image: self.image)
            self.setNeedUpdate()
        }
    }
    public var mode: QImageViewMode {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(mode: self.mode)
        }
    }
    public var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
        }
    }
    public var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
        }
    }
    public var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< ImageView >
    private var _view: ImageView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        image: QImage,
        mode: QImageViewMode = .aspectFit,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.width = width
        self.height = height
        self.image = image
        self.mode = mode
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem()
    }
    
    public func size(_ available: QSize) -> QSize {
        if let width = self.width, let height = self.height {
            return available.apply(width: width, height: height)
        } else if let width = self.width {
            return self.mode.size(
                size: self.image.size,
                available: QSize(
                    width: available.width.apply(width),
                    height: .infinity
                )
            )
        } else if let height = self.height {
            return self.mode.size(
                size: self.image.size,
                available: QSize(
                    width: .infinity,
                    height: available.height.apply(height)
                )
            )
        }
        return self.mode.size(size: self.image.size, available: available)
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.unload(owner: self)
        self.layout = nil
        self._onDisappear?()
    }
    
    @discardableResult
    public func width(_ value: QDimensionBehaviour?) -> Self {
        self.width = value
        return self
    }
    
    @discardableResult
    public func height(_ value: QDimensionBehaviour?) -> Self {
        self.height = value
        return self
    }
    
    @discardableResult
    public func image(_ value: QImage) -> Self {
        self.image = value
        return self
    }
    
    @discardableResult
    public func mode(_ value: QImageViewMode) -> Self {
        self.mode = value
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
    public func alpha(_ value: Float) -> Self {
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

public extension QImageViewMode {
    
    @inlinable
    func size(size: QSize, available: QSize) -> QSize {
        switch self {
        case .origin:
            return size
        case .aspectFit:
            if available.isInfinite == true {
                return size
            } else if available.width.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.height * aspectRatio,
                    height: available.height
                )
            } else if available.height.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.width,
                    height: available.width / aspectRatio
                )
            }
            return size.aspectFit(size: available)
        case .aspectFill:
            if available.isInfinite == true {
                return size
            } else if available.width.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.height * aspectRatio,
                    height: available.height
                )
            } else if available.height.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.width,
                    height: available.width / aspectRatio
                )
            }
            return size.aspectFill(size: available)
        }
    }

}
