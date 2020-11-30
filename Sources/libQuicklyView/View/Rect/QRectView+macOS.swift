//
//  libQuicklyView
//

#if os(OSX)

import AppKit
import libQuicklyCore

extension QRectView {

    final class RectView : NSView {
        
        var qFill: Fill! {
            didSet { self._updateFill() }
        }
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qCornerRadius: QRectView.CornerRadius = .none {
            didSet {
                self._updateCornerRadius()
            }
        }
        var qBorder: QRectView.Border = .none {
            didSet {
                self._updateBorder()
            }
        }
        var qShadow: QRectView.Shadow? {
            didSet {
                self._updateShadow()
            }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        override var frame: CGRect {
            didSet {
                if let layer = self.layer, let gradientLayer = self._gradientLayer {
                    CATransaction.withoutActions({
                        gradientLayer.frame = layer.bounds
                    })
                }
                self._updateCornerRadius()
            }
        }
        override var bounds: CGRect {
            didSet {
                self._updateCornerRadius()
            }
        }
        
        private var _gradientLayer: CAGradientLayer? {
            willSet {
                guard let gradientLayer = self._gradientLayer else { return }
                gradientLayer.removeFromSuperlayer()
            }
            didSet {
                guard let layer = self.layer, let gradientLayer = self._gradientLayer else { return }
                gradientLayer.frame = layer.bounds
                self.layer?.addSublayer(gradientLayer)
            }
        }
        
        init() {
            super.init(frame: .zero)
            
            self.wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func hitTest(_ point: NSPoint) -> NSView? {
            return nil
        }
        
    }
    
}

private extension QRectView.RectView {
    
    func _updateFill() {
        switch self.qFill {
        case .color(let value):
            self.layer?.backgroundColor = value.cgColor
            self._gradientLayer = nil
        case .gradient(let value):
            self.layer?.backgroundColor = .clear
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
            self.layer?.backgroundColor = .clear
            self._gradientLayer = nil
        }
    }
    
    func _updateCornerRadius() {
        switch self.qCornerRadius {
        case .none:
            self.layer!.cornerRadius = 0
        case .manual(let radius):
            self.layer!.cornerRadius = CGFloat(radius)
        case .auto:
            let boundsSize = self.bounds.size
            self.layer!.cornerRadius = CGFloat(ceil(min(boundsSize.width - 1, boundsSize.height - 1) / 2))
        }
    }

    func _updateBorder() {
        switch self.qBorder {
        case .none:
            self.layer!.borderWidth = 0
            self.layer!.borderColor = nil
            break
        case .manual(let width, let color):
            self.layer!.borderWidth = CGFloat(width)
            self.layer!.borderColor = color.cgColor
            break
        }
    }

    func _updateShadow() {
        if let shadow = self.qShadow {
            self.layer!.shadowColor = shadow.color.cgColor
            self.layer!.shadowOpacity = Float(shadow.opacity)
            self.layer!.shadowRadius = CGFloat(shadow.radius)
            self.layer!.shadowOffset = CGSize(
                width: CGFloat(shadow.offset.x),
                height: CGFloat(shadow.offset.y)
            )
            self.layer!.masksToBounds = false
        } else {
            self.layer!.shadowColor = nil
            self.layer!.masksToBounds = false
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
