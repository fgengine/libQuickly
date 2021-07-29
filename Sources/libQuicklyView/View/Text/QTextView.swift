//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QTextView : IQTextView {
    
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
    public var width: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public var height: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public var text: String {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(text: self.text)
            self.setNeedForceUpdate()
        }
    }
    public var textFont: QFont {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textFont: self.textFont)
            self.setNeedForceUpdate()
        }
    }
    public var textColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textColor: self.textColor)
        }
    }
    public var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alignment: self.alignment)
            self.setNeedUpdate()
        }
    }
    public var lineBreak: QTextLineBreak {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(lineBreak: self.lineBreak)
            self.setNeedForceUpdate()
        }
    }
    public var numberOfLines: UInt {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(numberOfLines: self.numberOfLines)
            self.setNeedForceUpdate()
        }
    }
    public var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
            self._view.updateShadowPath()
        }
    }
    public var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
            self._view.updateShadowPath()
        }
    }
    public var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< TextView >
    private var _view: TextView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        text: String,
        textFont: QFont,
        textColor: QColor,
        alignment: QTextAlignment = .left,
        lineBreak: QTextLineBreak = .wordWrapping,
        numberOfLines: UInt = 0,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.width = width
        self.height = height
        self.text = text
        self.textFont = textFont
        self.textColor = textColor
        self.alignment = alignment
        self.lineBreak = lineBreak
        self.numberOfLines = numberOfLines
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem()
    }
    
    public func size(_ available: QSize) -> QSize {
        if let width = self.width, let height = self.height {
            return available.apply(width: width, height: height)
        } else if let width = self.width {
            return self.text.size(font: self.textFont, available: QSize(
                width: available.width.apply(width),
                height: available.height
            ))
        } else if let height = self.height {
            return self.text.size(font: self.textFont, available: QSize(
                width: available.width,
                height: available.height.apply(height)
            ))
        }
        return self.text.size(font: self.textFont, available: available)
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.unload(owner: self)
        self.layout = nil
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
    public func text(_ value: String) -> Self {
        self.text = value
        return self
    }
    
    @discardableResult
    public func textFont(_ value: QFont) -> Self {
        self.textFont = value
        return self
    }
    
    @discardableResult
    public func textColor(_ value: QColor) -> Self {
        self.textColor = value
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
    public func alpha(_ value: Float) -> Self {
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
