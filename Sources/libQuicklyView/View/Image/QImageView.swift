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
    public private(set) var isVisible: Bool
    public var width: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var height: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var aspectRatio: Float? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var image: QImage {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(image: self.image)
            self.setNeedForceLayout()
        }
    }
    public var mode: QImageViewMode {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(mode: self.mode)
            self.setNeedForceLayout()
        }
    }
    public var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var tintColor: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(tintColor: self.tintColor)
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
        return self._reuse.content()
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    
    public init(
        reuseBehaviour: QReuseItemBehaviour = .unloadWhenDisappear,
        reuseName: String? = nil,
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        aspectRatio: Float? = nil,
        image: QImage,
        mode: QImageViewMode = .aspectFit,
        color: QColor? = nil,
        tintColor: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.isVisible = false
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.image = image
        self.mode = mode
        self.color = color
        self.tintColor = tintColor
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem(behaviour: reuseBehaviour, name: reuseName)
        self._reuse.configure(owner: self)
    }
    
    deinit {
        self._reuse.destroy()
    }
    
    public func loadIfNeeded() {
        self._reuse.loadIfNeeded()
    }
    
    public func size(_ available: QSize) -> QSize {
        if let width = self.width, let height = self.height {
            return available.apply(width: width, height: height, aspectRatio: self.aspectRatio)
        } else if let widthBehaviour = self.width, let width = widthBehaviour.value(available.width) {
            switch self.mode {
            case .origin:
                if let aspectRatio = self.aspectRatio {
                    return QSize(
                        width: width,
                        height: width / aspectRatio
                    )
                }
                return self.image.size
            case .aspectFit, .aspectFill:
                let aspectRatio = self.aspectRatio ?? self.image.size.aspectRatio
                return QSize(
                    width: width,
                    height: width / aspectRatio
                )
            }
        } else if let heightBehaviour = self.height, let height = heightBehaviour.value(available.height) {
            switch self.mode {
            case .origin:
                if let aspectRatio = self.aspectRatio {
                    return QSize(
                        width: height * aspectRatio,
                        height: height
                    )
                }
                return self.image.size
            case .aspectFit, .aspectFill:
                let aspectRatio = self.aspectRatio ?? self.image.size.aspectRatio
                return QSize(
                    width: height * aspectRatio,
                    height: height
                )
            }
        }
        switch self.mode {
        case .origin:
            if let aspectRatio = self.aspectRatio {
                if available.width.isInfinite == true && available.height.isInfinite == false {
                    return QSize(
                        width: available.height * aspectRatio,
                        height: available.height
                    )
                } else if available.width.isInfinite == false && available.height.isInfinite == true {
                    return QSize(
                        width: available.width,
                        height: available.width / aspectRatio
                    )
                }
            }
            return self.image.size
        case .aspectFit, .aspectFill:
            if available.isInfinite == true {
                return self.image.size
            } else if available.width.isInfinite == true {
                let aspectRatio = self.image.size.aspectRatio
                return QSize(
                    width: available.height * aspectRatio,
                    height: available.height
                )
            } else if available.height.isInfinite == true {
                let aspectRatio = self.image.size.aspectRatio
                return QSize(
                    width: available.width,
                    height: available.width / aspectRatio
                )
            }
            return self.image.size.aspectFit(size: available)
        }
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.disappear()
        self.layout = nil
        self._onDisappear?()
    }
    
    public func visible() {
        self.isVisible = true
        self._onVisible?()
    }
    
    public func visibility() {
        self._onVisibility?()
    }
    
    public func invisible() {
        self.isVisible = false
        self._onInvisible?()
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
    public func aspectRatio(_ value: Float?) -> Self {
        self.aspectRatio = value
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
    public func tintColor(_ value: QColor?) -> Self {
        self.tintColor = value
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
    
    @discardableResult
    public func onVisible(_ value: (() -> Void)?) -> Self {
        self._onVisible = value
        return self
    }
    
    @discardableResult
    public func onVisibility(_ value: (() -> Void)?) -> Self {
        self._onVisibility = value
        return self
    }
    
    @discardableResult
    public func onInvisible(_ value: (() -> Void)?) -> Self {
        self._onInvisible = value
        return self
    }

}
