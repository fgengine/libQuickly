//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QGradientView {
    
    final class GradientView : UIView {
        
        typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
        
        override class var layerClass: AnyClass {
            return CAGradientLayer.self
        }
        override var frame: CGRect {
            set(value) {
                if super.frame != value {
                    super.frame = value
                    if let view = self._view {
                        self.update(cornerRadius: view.cornerRadius)
                        self.updateShadowPath()
                    }
                }
            }
            get { return super.frame }
        }
        
        private unowned var _view: View?
        private var _layer: CAGradientLayer {
            return super.layer as! CAGradientLayer
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QGradientView.GradientView {
    
    func update(view: QGradientView) {
        self._view = view
        self.update(fill: view.fill)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(fill: QGradientViewFill) {
        switch fill.mode {
        case .axial: self._layer.type = .axial
        case .radial: self._layer.type = .radial
        }
        self._layer.colors = fill.points.compactMap({ return $0.color.cgColor })
        self._layer.locations = fill.points.compactMap({ return NSNumber(value: $0.location) })
        self._layer.startPoint = fill.start.cgPoint
        self._layer.endPoint = fill.end.cgPoint
    }
    
    func cleanup() {
        self._view = nil
    }
    
}

extension QGradientView.GradientView : IQReusable {
    
    typealias Owner = QGradientView
    typealias Content = QGradientView.GradientView

    static var reuseIdentificator: String {
        return "QGradientView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: CGRect.zero)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(owner: Owner, content: Content) {
        content.cleanup()
    }
    
}

#endif
