//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QBlurView {
    
    final class BlurView : UIVisualEffectView {
        
        var qGrayscaleTintLevel: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.grayscaleTintLevel) }
            get { return self._get(blurKeyPath: BlurKeyPath.grayscaleTintLevel, empty: 0) }
        }
        var qGrayscaleTintAlpha: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.grayscaleTintAlpha) }
            get { return self._get(blurKeyPath: BlurKeyPath.grayscaleTintAlpha, empty: 1) }
        }
        var qLightenGrayscaleWithSourceOver: Bool {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.lightenGrayscaleWithSourceOver) }
            get { return self._get(blurKeyPath: BlurKeyPath.lightenGrayscaleWithSourceOver, empty: false) }
        }
        var qColorTint: QColor? {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.colorTint) }
            get { return self._get(blurKeyPath: BlurKeyPath.colorTint, empty: nil) }
        }
        var qColorTintAlpha: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.colorTintAlpha) }
            get { return self._get(blurKeyPath: BlurKeyPath.colorTintAlpha, empty: 0) }
        }
        var qColorBurnTintLevel: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.colorBurnTintLevel) }
            get { return self._get(blurKeyPath: BlurKeyPath.colorBurnTintLevel, empty: 0) }
        }
        var qColorBurnTintAlpha: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.colorBurnTintAlpha) }
            get { return self._get(blurKeyPath: BlurKeyPath.colorBurnTintAlpha, empty: 1) }
        }
        var qDarkeningTintAlpha: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.darkeningTintAlpha) }
            get { return self._get(blurKeyPath: BlurKeyPath.darkeningTintAlpha, empty: 1) }
        }
        var qDarkeningTintHue: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.darkeningTintHue) }
            get { return self._get(blurKeyPath: BlurKeyPath.darkeningTintHue, empty: 0) }
        }
        var qDarkeningTintSaturation: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.darkeningTintSaturation) }
            get { return self._get(blurKeyPath: BlurKeyPath.darkeningTintSaturation, empty: 0) }
        }
        var qDarkenWithSourceOver: Bool {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.darkenWithSourceOver) }
            get { return self._get(blurKeyPath: BlurKeyPath.darkenWithSourceOver, empty: false) }
        }
        var qSaturationDeltaFactor: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.saturationDeltaFactor) }
            get { return self._get(blurKeyPath: BlurKeyPath.saturationDeltaFactor, empty: 0) }
        }
        var qRadius: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.radius) }
            get { return self._get(blurKeyPath: BlurKeyPath.radius, empty: 0) }
        }
        var qScale: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.scale) }
            get { return self._get(blurKeyPath: BlurKeyPath.scale, empty: 0) }
        }
        var qZoom: QFloat {
            set(value) { self._set(value, blurKeyPath: BlurKeyPath.zoom) }
            get { return self._get(blurKeyPath: BlurKeyPath.zoom, empty: 0) }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _blurEffect: UIBlurEffect
        
        init() {
            self._blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
            
            super.init(effect: nil)
            
            self.backgroundColor = .clear
            self.isUserInteractionEnabled = false
            self.clipsToBounds = true
            self.isOpaque = false
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

private extension QBlurView.BlurView {
    
    struct BlurKeyPath {

        static let grayscaleTintLevel: String = "grayscaleTintLevel"
        static let grayscaleTintAlpha: String = "grayscaleTintAlpha"
        static let lightenGrayscaleWithSourceOver: String = "lightenGrayscaleWithSourceOver"
        static let colorTint: String = "colorTint"
        static let colorTintAlpha: String = "colorTintAlpha"
        static let colorBurnTintLevel: String = "colorBurnTintLevel"
        static let colorBurnTintAlpha: String = "colorBurnTintAlpha"
        static let darkeningTintAlpha: String = "darkeningTintAlpha"
        static let darkeningTintHue: String = "darkeningTintHue"
        static let darkeningTintSaturation: String = "darkeningTintSaturation"
        static let darkenWithSourceOver: String = "darkenWithSourceOver"
        static let saturationDeltaFactor: String = "saturationDeltaFactor"
        static let radius: String = "blurRadius"
        static let scale: String = "scale"
        static let zoom: String = "zoom"

    }
    
}

private extension QBlurView.BlurView {
    
    func _set(_ value: Any?, blurKeyPath: String) {
        self._blurEffect.setValue(value, forKeyPath: blurKeyPath)
        self.effect = self._blurEffect
    }
    
    func _get(blurKeyPath: String) -> Any? {
        return self._blurEffect.value(forKeyPath: blurKeyPath)
    }
    
    func _set(_ value: NSNumber, blurKeyPath: String) {
        self._set(value as Any?, blurKeyPath: blurKeyPath)
    }
    
    func _get(blurKeyPath: String, empty: NSNumber) -> NSNumber {
        guard let number = self._get(blurKeyPath: blurKeyPath) as? NSNumber else { return empty }
        return number
    }
    
    func _set(_ value: Bool, blurKeyPath: String) {
        self._set(NSNumber(value: value), blurKeyPath: blurKeyPath)
    }
    
    func _get(blurKeyPath: String, empty: Bool) -> Bool {
        return self._get(blurKeyPath: blurKeyPath, empty: NSNumber(value: empty)).boolValue
    }
    
    func _set(_ value: QFloat, blurKeyPath: String) {
        self._set(NSNumber(value: value), blurKeyPath: blurKeyPath)
    }
    
    func _get(blurKeyPath: String, empty: QFloat) -> QFloat {
        return QFloat(self._get(blurKeyPath: blurKeyPath, empty: NSNumber(value: empty)).floatValue)
    }
    
    func _set(_ value: QColor?, blurKeyPath: String) {
        self._set(value as Any?, blurKeyPath: blurKeyPath)
    }
    
    func _get(blurKeyPath: String, empty: QColor?) -> QColor? {
        guard let color = self._get(blurKeyPath: blurKeyPath) as? QColor else { return empty }
        return color
    }
    
}

extension QBlurView.BlurView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return true
    }
    
    func updateBlending(superview: QNativeView) {
    }
    
}

extension QBlurView.BlurView : IQReusable {
    
    typealias View = QBlurView
    typealias Item = QBlurView.BlurView

    static var reuseIdentificator: String {
        return "QBlurView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qGrayscaleTintLevel = view.grayscaleTintLevel
        item.qGrayscaleTintAlpha = view.grayscaleTintAlpha
        item.qLightenGrayscaleWithSourceOver = view.lightenGrayscaleWithSourceOver
        item.qColorTint = view.colorTint
        item.qColorTintAlpha = view.colorTintAlpha
        item.qColorBurnTintLevel = view.colorBurnTintLevel
        item.qColorBurnTintAlpha = view.colorBurnTintAlpha
        item.qDarkeningTintHue = view.darkeningTintHue
        item.qDarkeningTintSaturation = view.darkeningTintSaturation
        item.qDarkeningTintAlpha = view.darkeningTintAlpha
        item.qDarkenWithSourceOver = view.darkenWithSourceOver
        item.qSaturationDeltaFactor = view.saturationDeltaFactor
        item.qRadius = view.radius
        item.qScale = view.scale
        item.qZoom = view.zoom
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
