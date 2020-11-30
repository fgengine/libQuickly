//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QRectView {
    
    final class RectView : UIView {
        
        var qFill: Fill! {
            didSet { self._updateFill() }
        }
        var qCornerRadius: QRectView.CornerRadius = .none {
            didSet {
                self._updateCornerRadius()
                self._updateShadowPath()
            }
        }
        var qBorder: QRectView.Border = .none {
            didSet {
                self._updateBorder()
                self._updateShadowPath()
            }
        }
        var qShadow: QRectView.Shadow? {
            didSet {
                self._updateShadow()
                self._updateShadowPath()
            }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        override var frame: CGRect {
            didSet {
                if let gradientLayer = self._gradientLayer {
                    CATransaction.withoutActions({
                        gradientLayer.frame = self.layer.bounds
                    })
                }
                self._updateCornerRadius()
                self._updateShadowPath()
            }
        }
        override var bounds: CGRect {
            didSet {
                self._updateCornerRadius()
                self._updateShadowPath()
            }
        }
        
        private var _gradientLayer: CAGradientLayer? {
            willSet {
                guard let gradientLayer = self._gradientLayer else { return }
                gradientLayer.removeFromSuperlayer()
            }
            didSet {
                guard let gradientLayer = self._gradientLayer else { return }
                gradientLayer.frame = self.layer.bounds
                self.layer.addSublayer(gradientLayer)
            }
        }
        
        init() {
            super.init(frame: CGRect.zero)
            
            self.isUserInteractionEnabled = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

private extension QRectView.RectView {
    
    func _updateFill() {
        switch self.qFill {
        case .color(let value):
            self.backgroundColor = value.native
            self._gradientLayer = nil
        case .gradient(let value):
            self.backgroundColor = .clear
            let type: CAGradientLayerType
            switch value.mode {
            case .axial: type = .axial
            case .radial: type = .radial
            }
            if let gradientLayer = self._gradientLayer {
                CATransaction.withoutActions({
                    gradientLayer.type = type
                    gradientLayer.colors = value.points.compactMap({ return $0.color.cgColor })
                    gradientLayer.locations = value.points.compactMap({ return NSNumber(value: $0.location) })
                    gradientLayer.startPoint = value.start.cgPoint
                    gradientLayer.endPoint = value.end.cgPoint
                })
            } else {
                let gradientLayer = CAGradientLayer()
                gradientLayer.type = type
                gradientLayer.colors = value.points.compactMap({ return $0.color.cgColor })
                gradientLayer.locations = value.points.compactMap({ return NSNumber(value: $0.location) })
                gradientLayer.startPoint = value.start.cgPoint
                gradientLayer.endPoint = value.end.cgPoint
                self._gradientLayer = gradientLayer
            }
        case .none:
            self.backgroundColor = .clear
            self._gradientLayer = nil
        }
    }
    
    func _updateCornerRadius() {
        switch self.qCornerRadius {
        case .none:
            self.layer.cornerRadius = 0
        case .manual(let radius):
            self.layer.cornerRadius = CGFloat(radius)
        case .auto:
            let boundsSize = self.bounds.size
            self.layer.cornerRadius = CGFloat(ceil(min(boundsSize.width - 1, boundsSize.height - 1) / 2))
        }
    }

    func _updateBorder() {
        switch self.qBorder {
        case .none:
            self.layer.borderWidth = 0
            self.layer.borderColor = nil
            break
        case .manual(let width, let color):
            self.layer.borderWidth = CGFloat(width)
            self.layer.borderColor = color.cgColor
            break
        }
    }

    func _updateShadow() {
        if let shadow = self.qShadow {
            self.layer.shadowColor = shadow.color.cgColor
            self.layer.shadowOpacity = Float(shadow.opacity)
            self.layer.shadowRadius = CGFloat(shadow.radius)
            self.layer.shadowOffset = CGSize(
                width: CGFloat(shadow.offset.x),
                height: CGFloat(shadow.offset.y)
            )
            self.clipsToBounds = false
        } else {
            self.layer.shadowColor = nil
            self.clipsToBounds = true
        }
    }

    func _updateShadowPath() {
        if self.layer.shadowColor != nil {
            let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius)
            self.layer.shadowPath = path.cgPath
        } else {
            self.layer.shadowPath = nil
        }
    }
    
}

extension QRectView.RectView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        switch self.qCornerRadius {
        case .none: break
        case .manual(let radius): return radius > 0
        case .auto: return true
        }
        switch self.qFill {
        case .color(let value): return value.isOpaque == false || self.alpha < 1
        case .gradient(let value): return value.isOpaque == false || self.alpha < 1
        case .none: return self.alpha < 1
        }
    }
    
    func updateBlending(superview: QNativeView) {
        if self.allowBlending() == true || superview.allowBlending() == true {
            self.isOpaque = false
        } else {
            self.isOpaque = true
        }
    }
    
}

extension QRectView.RectView : IQReusable {
    
    typealias View = QRectView
    typealias Item = QRectView.RectView

    static var reuseIdentificator: String {
        return "QRectView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qFill = view.fill
        item.qCornerRadius = view.cornerRadius
        item.qBorder = view.border
        item.qShadow = view.shadow
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
