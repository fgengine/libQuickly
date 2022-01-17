//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol AttributedTextViewDelegate : AnyObject {
    
    func shouldTap() -> Bool
    func tap(attributes: [NSAttributedString.Key: Any]?)
    
}

public class QAttributedTextView : IQAttributedTextView {
    
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
    public var isHidden: Bool {
        didSet(oldValue) {
            guard self.isHidden != oldValue else { return }
            self.setNeedForceLayout()
        }
    }
    public var width: QDimensionBehaviour? {
        didSet(oldValue) {
            guard self.width != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._cacheAvailable = nil
            self._cacheSize = nil
            self.setNeedForceLayout()
        }
    }
    public var height: QDimensionBehaviour? {
        didSet(oldValue) {
            guard self.height != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._cacheAvailable = nil
            self._cacheSize = nil
            self.setNeedForceLayout()
        }
    }
    public var text: NSAttributedString {
        didSet(oldValue) {
            guard self.text != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(text: self.text, alignment: self.alignment)
            self._cacheAvailable = nil
            self._cacheSize = nil
            self.setNeedForceLayout()
        }
    }
    public var alignment: QTextAlignment? {
        didSet(oldValue) {
            guard self.alignment != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(alignment: self.alignment)
            self.setNeedLayout()
        }
    }
    public var lineBreak: QTextLineBreak {
        didSet(oldValue) {
            guard self.lineBreak != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(lineBreak: self.lineBreak)
            self.setNeedForceLayout()
        }
    }
    public var numberOfLines: UInt {
        didSet(oldValue) {
            guard self.numberOfLines != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(numberOfLines: self.numberOfLines)
            self.setNeedForceLayout()
        }
    }
    public var color: QColor? {
        didSet(oldValue) {
            guard self.color != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var border: QViewBorder {
        didSet(oldValue) {
            guard self.border != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public var cornerRadius: QViewCornerRadius {
        didSet(oldValue) {
            guard self.cornerRadius != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
            self._view.updateShadowPath()
        }
    }
    public var shadow: QViewShadow? {
        didSet(oldValue) {
            guard self.shadow != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
            self._view.updateShadowPath()
        }
    }
    public var alpha: Float {
        didSet(oldValue) {
            guard self.alpha != oldValue else { return }
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< AttributedTextView >
    private var _view: AttributedTextView {
        return self._reuse.content()
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    private var _onTap: ((_ attributes: [NSAttributedString.Key: Any]?) -> Void)?
    private var _cacheAvailable: QSize?
    private var _cacheSize: QSize?
    
    public init(
        reuseBehaviour: QReuseItemBehaviour = .unloadWhenDisappear,
        reuseName: String? = nil,
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        text: NSAttributedString,
        alignment: QTextAlignment? = nil,
        lineBreak: QTextLineBreak = .wordWrapping,
        numberOfLines: UInt = 0,
        color: QColor? = QColor(r: 0.0, g: 0.0, b: 0.0, a: 0.0),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.isVisible = false
        self.width = width
        self.height = height
        self.text = text
        self.alignment = alignment
        self.lineBreak = lineBreak
        self.numberOfLines = numberOfLines
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self.isHidden = isHidden
        self._reuse = QReuseItem(behaviour: reuseBehaviour, name: reuseName)
        self._reuse.configure(owner: self)
    }
    
    deinit {
        self._reuse.destroy()
    }
    
    public func loadIfNeeded() {
        self._reuse.loadIfNeeded()
    }
    
    public func size(available: QSize) -> QSize {
        guard self.isHidden == false else { return .zero }
        if let cacheAvailable = self._cacheAvailable, let cacheSize = self._cacheSize {
            if cacheAvailable == available {
                return cacheSize
            } else {
                self._cacheAvailable = nil
                self._cacheSize = nil
            }
        }
        let size: QSize
        if let width = self.width, let height = self.height {
            size = available.apply(width: width, height: height)
        } else if let width = self.width {
            let availableSize = QSize(
                width: width.value(available.width) ?? 0,
                height: available.height
            )
            let textSize = self.text.size(available: availableSize)
            size = QSize(
                width: availableSize.width,
                height: textSize.height
            )
        } else if let height = self.height {
            let availableSize = QSize(
                width: available.width,
                height: height.value(available.height) ?? 0
            )
            let textSize = self.text.size(available: availableSize)
            size = QSize(
                width: textSize.width,
                height: availableSize.height
            )
        } else {
            size = self.text.size(available: available)
        }
        self._cacheAvailable = available
        self._cacheSize = size
        return size
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
    public func text(_ value: NSAttributedString) -> Self {
        self.text = value
        return self
    }
    
    @discardableResult
    public func alignment(_ value: QTextAlignment?) -> Self {
        self.alignment = value
        return self
    }
    
    @discardableResult
    public func lineBreak(_ value: QTextLineBreak) -> Self {
        self.lineBreak = value
        return self
    }
    
    @discardableResult
    public func numberOfLines(_ value: UInt) -> Self {
        self.numberOfLines = value
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
    public func hidden(_ value: Bool) -> Self {
        self.isHidden = value
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
    
    @discardableResult
    public func onTap(_ value: ((_ attributes: [NSAttributedString.Key: Any]?) -> Void)?) -> Self {
        self._onTap = value
        return self
    }

}

extension QAttributedTextView : AttributedTextViewDelegate {
    
    func shouldTap() -> Bool {
        return self._onTap != nil
    }
    
    func tap(attributes: [NSAttributedString.Key: Any]?) {
        self._onTap?(attributes)
    }
    
}
