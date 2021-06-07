//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QCellView< ContentView : IQView > : IQCellView {
    
    public var layout: IQLayout? {
        get { return self._view.layout }
    }
    public unowned var item: QLayoutItem? {
        set(value) { self._view.item = value }
        get { return self._view.item }
    }
    public var native: QNativeView {
        return self._view.native
    }
    public var isLoaded: Bool {
        return self._view.isLoaded
    }
    public var bounds: QRect {
        return self._view.bounds
    }
    public var shouldHighlighting: Bool {
        get { return self._view.shouldHighlighting }
    }
    public var isHighlighted: Bool {
        get { return self._view.isHighlighted }
    }
    public private(set) var shouldPressed: Bool
    public private(set) var contentView: ContentView {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._layout.contentItem = QLayoutItem(view: self.contentView)
        }
    }
    public var color: QColor? {
        get { return self._view.color }
    }
    public var cornerRadius: QViewCornerRadius {
        get { return self._view.cornerRadius }
    }
    public var border: QViewBorder {
        get { return self._view.border }
    }
    public var shadow: QViewShadow? {
        get { return self._view.shadow }
    }
    public var alpha: Float {
        get { return self._view.alpha }
    }
    
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _pressedGesture: IQTapGesture
    #endif
    private var _onPressed: (() -> Void)?
    
    public init(
        shouldPressed: Bool = true,
        contentView: ContentView,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.shouldPressed = shouldPressed
        self.contentView = contentView
        self._layout = Layout(
            contentItem: QLayoutItem(view: contentView)
        )
        #if os(iOS)
        self._pressedGesture = QTapGesture()
        self._view = QCustomView(
            gestures: [ self._pressedGesture ],
            contentLayout: self._layout,
            shouldHighlighting: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        #else
        self._view = QCustomView(
            layout: self._layout,
            shouldHighlighting: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        #endif
        self._init()
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
        self._view.triggeredChangeStyle(userIteraction)
    }
    
    @discardableResult
    public func shouldHighlighting(_ value: Bool) -> Self {
        self._view.shouldHighlighting(value)
        return self
    }
    
    @discardableResult
    public func highlight(_ value: Bool) -> Self {
        self._view.highlight(value)
        return self
    }
    
    @discardableResult
    public func shouldPressed(_ value: Bool) -> Self {
        self.shouldPressed = value
        return self
    }
    
    @discardableResult
    public func contentView(_ value: ContentView) -> Self {
        self.contentView = value
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
    public func alpha(_ value: Float) -> Self {
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
        self._onPressed = value
        return self
    }
    
}

private extension QCellView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var contentItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }

        init(
            contentItem: QLayoutItem
        ) {
            self.contentItem = contentItem
        }
        
        func invalidate(item: QLayoutItem) {
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            let contentSize = self.contentItem.size(available)
            return QSize(width: available.width, height: contentSize.height)
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            return [ self.contentItem ]
        }
        
    }
    
}

private extension QCellView {
    
    func _init() {
        #if os(iOS)
        self._pressedGesture.onShouldBegin({ [unowned self] in
            guard self.shouldPressed == true else { return false }
            guard self._pressedGesture.contains(in: self.contentView) == true else { return false }
            return true
        }).onTriggered({ [unowned self] in
            self._pressed()
        })
        #endif
    }
    
    #if os(iOS)
    
    func _pressed() {
        self._onPressed?()
    }
    
    #endif
    
}
