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
        
        static func cleanupReuse(content: Content) {
            content.cleanup()
        }
        
    }
    
}

final class NativeControlView : UIControl {
    
    typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
    
    unowned var customDelegate: NativeControlViewDelegate?
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
    private var _isLayout: Bool
    
    override init(frame: CGRect) {
        self._isLayout = false
        
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(self._handleHighlighting(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(self._handleHighlighting(_:)), for: .touchDragEnter)
        self.addTarget(self, action: #selector(self._handleUnhighlighting(_:)), for: .touchDragExit)
        self.addTarget(self, action: #selector(self._handleUnhighlighting(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(self._handleUnhighlighting(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(self._handlePressed(_:)), for: .touchUpInside)
        self.clipsToBounds = true
        
        self._layoutManager = QLayoutManager(contentView: self, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview superview: UIView?) {
        super.willMove(toSuperview: superview)
        
        if superview == nil {
            self._layoutManager.clear()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self._safeLayout({
            let bounds = QRect(self.bounds)
            self._layoutManager.layout(bounds:bounds)
            self._layoutManager.visible(bounds: bounds)
        })
    }
    
}

extension NativeControlView {
    
    func update< Layout : IQLayout >(view: QControlView< Layout >) {
        self._view = view
        self.update(contentLayout: view.contentLayout)
        self.update(locked: view.isLocked)
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

private extension NativeControlView {
    
    func _safeLayout(_ action: () -> Void) {
        if self._isLayout == false {
            self._isLayout = true
            action()
            self._isLayout = false
        }
    }
    
    @objc
    func _handleHighlighting(_ sender: Any) {
        if self.customDelegate?.shouldHighlighting(view: self) == true {
            self.customDelegate?.set(view: self, highlighted: true)
        }
    }
    
    @objc
    func _handleUnhighlighting(_ sender: Any) {
        if self.customDelegate?.shouldHighlighting(view: self) == true {
            self.customDelegate?.set(view: self, highlighted: false)
        }
    }
    
    @objc
    func _handlePressed(_ sender: Any) {
        if self.customDelegate?.shouldPressing(view: self) == true {
            self.customDelegate?.pressed(view: self)
        }
        if self.customDelegate?.shouldHighlighting(view: self) == true {
            self.customDelegate?.set(view: self, highlighted: false)
        }
    }
    
}

extension NativeControlView : IQLayoutDelegate {
    
    func setNeedUpdate(_ layout: IQLayout) -> Bool {
        self.setNeedsLayout()
        return true
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
        self.layoutIfNeeded()
    }
    
}

#endif
