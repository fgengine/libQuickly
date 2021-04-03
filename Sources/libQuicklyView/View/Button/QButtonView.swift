//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QButtonView : IQButtonView {
    
    public var parentLayout: IQLayout? {
        get { return self._view.parentLayout }
    }
    public unowned var item: QLayoutItem? {
        set(value) { self._view.item = value }
        get { return self._view.item }
    }
    public var name: String {
        return self._view.name
    }
    public var native: QNativeView {
        return self._view.native
    }
    public var isLoaded: Bool {
        return self._view.isLoaded
    }
    public var isAppeared: Bool {
        return self._view.isAppeared
    }
    public var bounds: QRect {
        return self._view.bounds
    }
    public private(set) var inset: QInset {
        set(value) {
            self._layout.inset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.inset }
    }
    public private(set) var backgroundView: IQView
    public private(set) var spinnerPosition: QButtonViewSpinnerPosition {
        set(value) {
            self._layout.spinnerPosition = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.spinnerPosition }
    }
    public private(set) var spinnerAnimating: Bool {
        set(value) {
            self._layout.spinnerAnimating = value
            self.spinnerView?.animating(value)
            self._layout.setNeedUpdate()
        }
        get { return self._layout.spinnerAnimating }
    }
    public private(set) var spinnerView: IQSpinnerView?
    public private(set) var imagePosition: QButtonViewImagePosition {
        set(value) {
            self._layout.imagePosition = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.imagePosition }
    }
    public private(set) var imageInset: QInset {
        set(value) {
            self._layout.imageInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.imageInset }
    }
    public private(set) var imageView: IQView?
    public private(set) var textInset: QInset {
        set(value) {
            self._layout.textInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.textInset }
    }
    public private(set) var textView: IQView?
    public private(set) var isHighlighted: Bool {
        set(value) {
            if self._isHighlighted != value {
                self._isHighlighted = value
                self.triggeredChangeStyle(false)
            }
        }
        get { return self._isHighlighted }
    }
    public private(set) var isSelected: Bool {
        set(value) {
            if self._isSelected != value {
                self._isSelected = value
                self.triggeredChangeStyle(false)
            }
        }
        get { return self._isSelected }
    }
    public var color: QColor? {
        get { return self._view.color }
    }
    public var border: QViewBorder {
        get { return self._view.border }
    }
    public var cornerRadius: QViewCornerRadius {
        get { return self._view.cornerRadius }
    }
    public var shadow: QViewShadow? {
        get { return self._view.shadow }
    }
    public var alpha: QFloat {
        get { return self._view.alpha }
    }
    
    private var _layout: Layout
    private var _view: IQControlView
    private var _isHighlighted: Bool
    private var _isSelected: Bool
    private var _onChangeStyle: ((_ userIteraction: Bool) -> Void)?
    private var _onPressed: (() -> Void)?
    
    public init(
        name: String? = nil,
        inset: QInset = QInset(horizontal: 4, vertical: 4),
        backgroundView: IQView,
        spinnerPosition: QButtonViewSpinnerPosition = .fill,
        spinnerView: IQSpinnerView? = nil,
        spinnerAnimating: Bool = false,
        imagePosition: QButtonViewImagePosition = .left,
        imageInset: QInset = QInset(horizontal: 4, vertical: 4),
        imageView: IQView? = nil,
        textInset: QInset = QInset(horizontal: 4, vertical: 4),
        textView: IQView? = nil,
        isHighlighted: Bool = false,
        isSelected: Bool = false,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        let name = name ?? String(describing: Self.self)
        self.backgroundView = backgroundView
        self.spinnerView = spinnerView
        self.imageView = imageView
        self.textView = textView
        self._layout = Layout(
            inset: inset,
            backgroundItem: QLayoutItem(view: backgroundView),
            spinnerPosition: spinnerPosition,
            spinnerItem: spinnerView.flatMap({ return QLayoutItem(view: $0) }),
            spinnerAnimating: spinnerAnimating,
            imagePosition: imagePosition,
            imageInset: imageInset,
            imageItem: imageView.flatMap({ return QLayoutItem(view: $0) }),
            textInset: textInset,
            textItem: textView.flatMap({ return QLayoutItem(view: $0) })
        )
        self._view = QControlView(
            name: name,
            layout: self._layout,
            shouldHighlighting: true,
            shouldPressed: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        self._isHighlighted = isHighlighted
        self._isSelected = isSelected
    }
    
    public func size(_ available: QSize) -> QSize {
        return self._view.size(available)
    }
    
    public func appear(to layout: IQLayout) {
        self._view.appear(to: layout)
    }
    
    public func disappear() {
        self._view.disappear()
    }
    
    public func triggeredChangeStyle(_ userIteraction: Bool) {
        self._onChangeStyle?(userIteraction)
    }
    
    @discardableResult
    public func inset(_ value: QInset) -> Self {
        self.inset = value
        return self
    }
    
    @discardableResult
    public func spinnerPosition(_ value: QButtonViewSpinnerPosition) -> Self {
        self.spinnerPosition = value
        return self
    }
    
    @discardableResult
    public func spinnerAnimating(_ value: Bool) -> Self {
        self.spinnerAnimating = value
        return self
    }
    
    @discardableResult
    public func imagePosition(_ value: QButtonViewImagePosition) -> Self {
        self.imagePosition = value
        return self
    }
    
    @discardableResult
    public func imageInset(_ value: QInset) -> Self {
        self.imageInset = value
        return self
    }
    
    @discardableResult
    public func textInset(_ value: QInset) -> Self {
        self.textInset = value
        return self
    }
    
    @discardableResult
    public func highlight(_ value: Bool) -> Self {
        self.isHighlighted = value
        return self
    }
    
    @discardableResult
    public func select(_ value: Bool) -> Self {
        self.isSelected = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self._view.color(value)
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self._view.border(value)
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self._view.cornerRadius(value)
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self._view.shadow(value)
        return self
    }
    
    @discardableResult
    public func alpha(_ value: QFloat) -> Self {
        self._view.alpha(value)
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._view.onAppear(value)
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._view.onDisappear(value)
        return self
    }
    
    @discardableResult
    public func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self {
        self._view.onChangeStyle(value)
        return self
    }
    
    @discardableResult
    public func onPressed(_ value: (() -> Void)?) -> Self {
        self._view.onPressed(value)
        return self
    }
    
}

extension QButtonView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var parentView: IQView?
        var inset: QInset
        var spinnerPosition: QButtonViewSpinnerPosition
        var spinnerItem: QLayoutItem?
        var spinnerAnimating: Bool
        var backgroundItem: QLayoutItem
        var imagePosition: QButtonViewImagePosition
        var imageInset: QInset
        var imageItem: QLayoutItem?
        var textInset: QInset
        var textItem: QLayoutItem?

        init(
            inset: QInset,
            backgroundItem: QLayoutItem,
            spinnerPosition: QButtonViewSpinnerPosition,
            spinnerItem: QLayoutItem?,
            spinnerAnimating: Bool,
            imagePosition: QButtonViewImagePosition,
            imageInset: QInset,
            imageItem: QLayoutItem?,
            textInset: QInset,
            textItem: QLayoutItem?
        ) {
            self.inset = inset
            self.backgroundItem = backgroundItem
            self.spinnerPosition = spinnerPosition
            self.spinnerItem = spinnerItem
            self.spinnerAnimating = spinnerAnimating
            self.imagePosition = imagePosition
            self.imageInset = imageInset
            self.imageItem = imageItem
            self.textInset = textInset
            self.textItem = textItem
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            self.backgroundItem.frame = bounds
            if self.spinnerAnimating == true, let spinnerItem = self.spinnerItem {
                let spinnerSize = spinnerItem.size(bounds.size)
                switch self.spinnerPosition {
                case .fill:
                    spinnerItem.frame = QRect(center: bounds.center, size: spinnerSize)
                case .image:
                    if self.imageItem != nil, let textItem = self.textItem {
                        let textSize = textItem.size(bounds.size)
                        let frames = self._frame(
                            position: self.imagePosition,
                            bounds: bounds,
                            primarySize: spinnerSize,
                            primaryInset: self.imageInset,
                            secondarySize: textSize,
                            secondaryInset: self.textInset
                        )
                        spinnerItem.frame = frames.primary
                        textItem.frame = frames.secondary
                    } else {
                        spinnerItem.frame = QRect(center: bounds.center, size: spinnerSize)
                    }
                }
            } else if let imageItem = self.imageItem, let textItem = self.textItem {
                let imageSize = imageItem.size(bounds.size)
                let textSize = textItem.size(bounds.size)
                let frames = self._frame(
                    position: self.imagePosition,
                    bounds: bounds,
                    primarySize: imageSize,
                    primaryInset: self.imageInset,
                    secondarySize: textSize,
                    secondaryInset: self.textInset
                )
                imageItem.frame = frames.primary
                textItem.frame = frames.secondary
            } else if let imageItem = self.imageItem {
                let imageSize = imageItem.size(bounds.size)
                imageItem.frame = QRect(center: bounds.center, size: imageSize)
            } else if let textItem = self.textItem {
                let textSize = textItem.size(bounds.size)
                textItem.frame = QRect(center: bounds.center, size: textSize)
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            var size = QSize(width: 0, height: 0)
            let spinnerSize = self.spinnerItem.flatMap({ return $0.size(available) })
            let imageSize = self.imageItem.flatMap({ return $0.size(available) })
            let textSize = self.textItem.flatMap({ return $0.size(available) })
            if self.spinnerAnimating == true, let spinnerSize = spinnerSize {
                switch self.spinnerPosition {
                case .fill:
                    size.width = self.inset.left + spinnerSize.width + self.inset.right
                    size.height = self.inset.top + spinnerSize.height + self.inset.bottom
                case .image:
                    if imageSize != nil, let textSize = textSize {
                        switch self.imagePosition {
                        case .top:
                            size.width = self.inset.left + max(spinnerSize.width, textSize.width) + self.inset.right
                            size.height = self.inset.top + spinnerSize.height + self.imageInset.bottom + self.textInset.top + textSize.height + self.inset.bottom
                        case .left:
                            size.width += self.inset.left + spinnerSize.width + self.imageInset.right + self.textInset.left + textSize.width + self.inset.right
                            size.height = self.inset.top + max(spinnerSize.height, textSize.height) + self.inset.bottom
                        case .right:
                            size.width = self.inset.left + textSize.width + self.textInset.right + self.imageInset.left + spinnerSize.width + self.inset.right
                            size.height = self.inset.top + max(spinnerSize.height, textSize.height) + self.inset.bottom
                        case .bottom:
                            size.width = self.inset.left + max(spinnerSize.width, textSize.width) + self.inset.right
                            size.height = self.inset.top + textSize.height + self.textInset.bottom + self.imageInset.top + spinnerSize.height + self.inset.bottom
                        }
                    } else {
                        size.width = self.inset.left + spinnerSize.width + self.inset.right
                        size.height = self.inset.top + spinnerSize.height + self.inset.bottom
                    }
                }
            } else if let imageSize = imageSize, let textSize = textSize {
                switch self.imagePosition {
                case .top:
                    size.width = self.inset.left + max(imageSize.width, textSize.width) + self.inset.right
                    size.height = self.inset.top + imageSize.height + self.imageInset.bottom + self.textInset.top + textSize.height + self.inset.bottom
                case .left:
                    size.width = self.inset.left + imageSize.width + self.imageInset.right + self.textInset.left + textSize.width + self.inset.right
                    size.height = self.inset.top + max(imageSize.height, textSize.height) + self.inset.bottom
                case .right:
                    size.width = self.inset.left + textSize.width + self.textInset.right + self.imageInset.left + imageSize.width + self.inset.right
                    size.height = self.inset.top + max(imageSize.height, textSize.height) + self.inset.bottom
                case .bottom:
                    size.width = self.inset.left + max(imageSize.width, textSize.width) + self.inset.right
                    size.height = self.inset.top + textSize.height + self.textInset.bottom + self.imageInset.top + imageSize.height + self.inset.bottom
                }
            } else if let imageSize = imageSize {
                size.width = self.inset.left + imageSize.width + self.inset.right
                size.height = self.inset.top + imageSize.height + self.inset.bottom
            } else if let textSize = textSize {
                size.width = self.inset.left + textSize.width + self.inset.right
                size.height = self.inset.top + textSize.height + self.inset.bottom
            }
            return size
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = [ self.backgroundItem ]
            if self.spinnerAnimating == true {
                if let item = self.spinnerItem {
                    items.append(item)
                }
            } else {
                if let item = self.imageItem {
                    items.append(item)
                }
                if let item = self.textItem {
                    items.append(item)
                }
            }
            return items
        }
        
    }
    
}

private extension QButtonView.Layout {
    
    func _frame(position: QButtonViewImagePosition, bounds: QRect, primarySize: QSize, primaryInset: QInset, secondarySize: QSize, secondaryInset: QInset) -> (primary: QRect, secondary: QRect) {
        var primary = QRect(topLeft: QPoint(), size: primarySize)
        var secondary = QRect(topLeft: QPoint(), size: secondarySize)
        switch position {
        case .top: secondary.origin.y = primaryInset.bottom + secondaryInset.top
        case .left: secondary.origin.x = primaryInset.right + secondaryInset.left
        case .right: primary.origin.x = secondaryInset.right + primaryInset.left
        case .bottom: primary.origin.y = secondaryInset.bottom + primaryInset.top
        }
        switch position {
        case .top, .bottom:
            let width = max(primary.size.width, secondary.size.width)
            primary.origin.x = (width - primary.size.width) / 2
            secondary.origin.x = (width - secondary.size.width) / 2
        case .left, .right:
            let height = max(primary.size.height, secondary.size.height)
            primary.origin.y = (height - primary.size.height) / 2
            secondary.origin.y = (height - secondary.size.height) / 2
        }
        let union = primary.union(secondary)
        let offset = QRect(center: bounds.center, size: union.size).origin
        return (
            primary: primary.offset(point: offset),
            secondary: secondary.offset(point: offset)
        )
    }
    
}
