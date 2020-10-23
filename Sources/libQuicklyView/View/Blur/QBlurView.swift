//
//  libQuicklyView
//

#if os(iOS)

import Foundation

public class QBlurView : IQView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var grayscaleTintLevel: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qGrayscaleTintLevel = self.grayscaleTintLevel
        }
    }
    public var grayscaleTintAlpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qGrayscaleTintAlpha = self.grayscaleTintAlpha
        }
    }
    public var lightenGrayscaleWithSourceOver: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qLightenGrayscaleWithSourceOver = self.lightenGrayscaleWithSourceOver
        }
    }
    public var colorTint: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColorTint = self.colorTint
        }
    }
    public var colorTintAlpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColorTintAlpha = self.colorTintAlpha
        }
    }
    public var colorBurnTintLevel: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColorBurnTintLevel = self.colorBurnTintLevel
        }
    }
    public var colorBurnTintAlpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColorBurnTintAlpha = self.colorBurnTintAlpha
        }
    }
    public var darkeningTintAlpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qDarkeningTintAlpha = self.darkeningTintAlpha
        }
    }
    public var darkeningTintHue: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qDarkeningTintHue = self.darkeningTintHue
        }
    }
    public var darkeningTintSaturation: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qDarkeningTintSaturation = self.darkeningTintSaturation
        }
    }
    public var darkenWithSourceOver: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qDarkenWithSourceOver = self.darkenWithSourceOver
        }
    }
    public var saturationDeltaFactor: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qSaturationDeltaFactor = self.saturationDeltaFactor
        }
    }
    public var radius: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qRadius = self.radius
        }
    }
    public var scale: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qScale = self.scale
        }
    }
    public var zoom: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qZoom = self.zoom
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
    
    private var _view: BlurView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< BlurView >
    
    public init(
        grayscaleTintLevel: QFloat = 0,
        grayscaleTintAlpha: QFloat = 1,
        lightenGrayscaleWithSourceOver: Bool = false,
        colorTint: QColor? = nil,
        colorTintAlpha: QFloat = 0,
        colorBurnTintLevel: QFloat = 0,
        colorBurnTintAlpha: QFloat = 1,
        darkeningTintHue: QFloat = 0,
        darkeningTintSaturation: QFloat = 0,
        darkeningTintAlpha: QFloat = 1,
        darkenWithSourceOver: Bool = false,
        saturationDeltaFactor: QFloat = 0,
        radius: QFloat,
        scale: QFloat = 1,
        zoom: QFloat = 1,
        alpha: QFloat = 1
    ) {
        self.grayscaleTintLevel = grayscaleTintLevel
        self.grayscaleTintAlpha = grayscaleTintAlpha
        self.lightenGrayscaleWithSourceOver = lightenGrayscaleWithSourceOver
        self.colorTint = colorTint
        self.colorTintAlpha = colorTintAlpha
        self.colorBurnTintLevel = colorBurnTintLevel
        self.colorBurnTintAlpha = colorBurnTintAlpha
        self.darkeningTintHue = darkeningTintHue
        self.darkeningTintSaturation = darkeningTintSaturation
        self.darkeningTintAlpha = darkeningTintAlpha
        self.darkenWithSourceOver = darkenWithSourceOver
        self.saturationDeltaFactor = saturationDeltaFactor
        self.radius = radius
        self.scale = scale
        self.zoom = zoom
        self.alpha = alpha
        self._reuseView = QReuseView()
    }

    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return available
    }
    
}

#endif
