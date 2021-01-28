//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QAttributedTextView : IQAttributedTextView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.isAppeared
    }
    public private(set) var width: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var height: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var text: NSAttributedString {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(text: self.text)
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alignment: self.alignment)
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var lineBreak: QTextLineBreak {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(lineBreak: self.lineBreak)
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var numberOfLines: UInt {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(numberOfLines: self.numberOfLines)
            self.parentLayout?.setNeedUpdate()
        }
    }
    public private(set) var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public private(set) var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public private(set) var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
            self._view.updateShadowPath()
        }
    }
    public private(set) var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
            self._view.updateShadowPath()
        }
    }
    public private(set) var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuseView: QReuseView< AttributedTextView >
    private var _view: AttributedTextView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        text: NSAttributedString,
        alignment: QTextAlignment = .left,
        lineBreak: QTextLineBreak = .wordWrapping,
        numberOfLines: UInt = 0,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
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
        self._reuseView = QReuseView()
    }
    
    public func size(_ available: QSize) -> QSize {
        if let width = self.width, let height = self.height {
            return available.apply(width: width, height: height)
        } else if let width = self.width {
            return self.text.size(available: QSize(
                width: available.width.apply(width),
                height: available.height
            ))
        } else if let height = self.height {
            return self.text.size(available: QSize(
                width: available.width,
                height: available.height.apply(height)
            ))
        }
        return self.text.size(available: available)
    }
    
    public func appear(to layout: IQLayout) {
        self.parentLayout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
        self._onDisappear?()
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
    public func alignment(_ value: QTextAlignment) -> Self {
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
    public func alpha(_ value: QFloat) -> Self {
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

}
