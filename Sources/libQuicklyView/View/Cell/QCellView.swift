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
    public var isVisible: Bool {
        return self._view.isVisible
    }
    public var isHidden: Bool {
        set(value) { self._view.isHidden = value }
        get { return self._view.isHidden }
    }
    public var shouldHighlighting: Bool {
        set(value) { self._view.shouldHighlighting = value }
        get { return self._view.shouldHighlighting }
    }
    public var isHighlighted: Bool {
        set(value) { self._view.isHighlighted = value }
        get { return self._view.isHighlighted }
    }
    public var shouldPressed: Bool
    public private(set) var contentView: ContentView {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._view.contentLayout.contentItem = QLayoutItem(view: self.contentView)
        }
    }
    public var color: QColor? {
        set(value) { self._view.color = value }
        get { return self._view.color }
    }
    public var cornerRadius: QViewCornerRadius {
        set(value) { self._view.cornerRadius = value }
        get { return self._view.cornerRadius }
    }
    public var border: QViewBorder {
        set(value) { self._view.border = value }
        get { return self._view.border }
    }
    public var shadow: QViewShadow? {
        set(value) { self._view.shadow = value }
        get { return self._view.shadow }
    }
    public var alpha: Float {
        set(value) { self._view.alpha = value }
        get { return self._view.alpha }
    }
    
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _pressedGesture: IQTapGesture
    #endif
    private var _onPressed: (() -> Void)?
    
    public init(
        shouldPressed: Bool = true,
        contentView: ContentView,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.shouldPressed = shouldPressed
        self.contentView = contentView
        #if os(iOS)
        self._pressedGesture = QTapGesture()
        self._view = QCustomView(
            gestures: [ self._pressedGesture ],
            contentLayout: Layout(
                contentItem: QLayoutItem(view: contentView)
            ),
            shouldHighlighting: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha,
            isHidden: isHidden
        )
        #else
        self._view = QCustomView(
            contentLayout: Layout(
                contentItem: QLayoutItem(view: contentView)
            ),
            shouldHighlighting: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha,
            isHidden: isHidden
        )
        #endif
        self._init()
    }
    
    public func loadIfNeeded() {
        self._view.loadIfNeeded()
    }
    
    public func size(available: QSize) -> QSize {
        return self._view.size(available: available)
    }
    
    public func appear(to layout: IQLayout) {
        self._view.appear(to: layout)
    }
    
    public func disappear() {
        self._view.disappear()
    }
    
    public func visible() {
        self._view.visible()
    }
    
    public func visibility() {
        self._view.visibility()
    }
    
    public func invisible() {
        self._view.invisible()
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
    public func hidden(_ value: Bool) -> Self {
        self._view.hidden(value)
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
    public func onVisible(_ value: (() -> Void)?) -> Self {
        self._view.onVisible(value)
        return self
    }
    
    @discardableResult
    public func onVisibility(_ value: (() -> Void)?) -> Self {
        self._view.onVisibility(value)
        return self
    }
    
    @discardableResult
    public func onInvisible(_ value: (() -> Void)?) -> Self {
        self._view.onInvisible(value)
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
            didSet { self.setNeedForceUpdate() }
        }

        init(
            contentItem: QLayoutItem
        ) {
            self.contentItem = contentItem
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            return bounds.size
        }
        
        func size(available: QSize) -> QSize {
            let contentSize = self.contentItem.size(available: available)
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
            return self.shouldPressed
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
