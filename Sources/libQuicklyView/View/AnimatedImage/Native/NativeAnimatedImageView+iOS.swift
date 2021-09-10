//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QAnimatedImageView {
    
    struct Reusable : IQReusable {
        
        typealias Owner = QAnimatedImageView
        typealias Content = NativeAnimatedImageView

        static var reuseIdentificator: String {
            return "QAnimatedImageView"
        }
        
        static func createReuse(owner: Owner) -> Content {
            return Content(frame: .zero)
        }
        
        static func configureReuse(owner: Owner, content: Content) {
            content.update(view: owner)
        }
        
        static func cleanupReuse(content: Content) {
            content.cleanup()
        }
        
    }
    
}

final class NativeAnimatedImageView : UIImageView {
    
    typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startAnimating() {
        super.startAnimating()
        if self.animationRepeatCount > 0 {
            self.image = self.animationImages?.last
        }
    }
    
}

extension NativeAnimatedImageView {
    
    func update(view: QAnimatedImageView) {
        self._view = view
        self.update(images: view.images)
        self.update(duration: view.duration)
        self.update(repeat: view.repeat)
        self.update(mode: view.mode)
        self.update(color: view.color)
        self.update(tintColor: view.tintColor)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(images: [QImage]) {
        self.animationImages = images.compactMap({ $0.native })
        self.image = self.animationImages?.first
    }
    
    func update(duration: TimeInterval) {
        self.animationDuration = duration
    }
    
    func update(repeat: QAnimatedImageViewRepeat) {
        switch `repeat` {
        case .loops(let count): self.animationRepeatCount = count
        case .infinity: self.animationRepeatCount = 0
        }
    }
    
    func update(mode: QAnimatedImageViewMode) {
        switch mode {
        case .origin: self.contentMode = .center
        case .aspectFit: self.contentMode = .scaleAspectFit
        case .aspectFill: self.contentMode = .scaleAspectFill
        }
    }
    
    func cleanup() {
        self.stopAnimating()
        self._view = nil
    }
    
}

#endif
