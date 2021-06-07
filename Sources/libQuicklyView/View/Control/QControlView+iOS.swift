//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QControlView {
    
    struct Reusable : IQReusable {
        
        typealias Owner = QControlView
        typealias Content = NativeControlView

        static var reuseIdentificator: String {
            return "QControlView"
        }
        
        static func createReuse(owner: Owner) -> Content {
            return Content(frame: .zero)
        }
        
        static func configureReuse(owner: Owner, content: Content) {
            content.update(view: owner)
        }
        
        static func cleanupReuse(owner: Owner, content: Content) {
            content.cleanup()
        }
        
    }
    
}

final class NativeControlView : UIControl {
    
    typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
    
    unowned var customDelegate: NativeControlViewDelegate!
    var contentSize: QSize {
        return self._layoutManager.size
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
    private var _layoutManager: QLayoutManager!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
        self._layoutManager = QLayoutManager(contentView: self, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview superview: UIView?) {
        super.willMove(toSuperview: superview)
        
        if superview != nil {
            self.setNeedsLayout()
        } else {
            self._layoutManager.clear()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = QRect(self.frame)
        self._layoutManager.layout(bounds: QRect(self.bounds))
        if self._layoutManager.size != frame.size {
            self._layoutManager.layout?.setNeedForceUpdate()
        }
        self._layoutManager.visible(bounds: QRect(self.bounds))
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.customDelegate.shouldHighlighting(view: self) == true || self.customDelegate.shouldPressing(view: self) == true {
            let hitView = super.hitTest(point, with: event)
            return hitView
        }
        if let hitView = super.hitTest(point, with: event) {
            if hitView != self {
                return hitView
            }
        }
        return nil
    }
    
    override func sendActions(for controlEvents: UIControl.Event) {
        super.sendActions(for: controlEvents)
        
        switch controlEvents {
        case .touchDown:
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: true)
            }
        case .touchDragEnter:
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: true)
            }
        case .touchDragExit:
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: false)
            }
        case .touchUpInside:
            if self.customDelegate.shouldPressing(view: self) == true {
                self.customDelegate.pressed(view: self)
            }
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: false)
            }
        case .touchUpOutside, .touchCancel:
            if self.customDelegate.shouldHighlighting(view: self) == true {
                self.customDelegate.set(view: self, highlighted: false)
            }
            
        default:
            break
        }
    }
    
}

extension NativeControlView {
    
    func update< View : IQControlView & NativeControlViewDelegate >(view: View) {
        self._view = view
        self.update(contentLayout: view.contentLayout)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
        self.customDelegate = view
    }
    
    func update(contentLayout: IQLayout) {
        self._layoutManager.layout = contentLayout
        self.setNeedsLayout()
    }
    
    func cleanup() {
        self._layoutManager.layout = nil
        self.customDelegate = nil
        self._view = nil
    }
    
}

extension NativeControlView : IQLayoutDelegate {
    
    func setNeedUpdate(_ layout: IQLayout, force: Bool) {
        if force == true {
            layout.view?.layout?.setNeedForceUpdate()
        }
        self.setNeedsLayout()
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
        layout.view?.layout?.updateIfNeeded()
        self.layoutIfNeeded()
    }
    
}

#endif
