//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

protocol InputToolbarViewDelegate : AnyObject {
    
    func pressed(barItem: UIBarButtonItem)
    
}

public struct QInputToolbarActionItem : IQInputToolbarItem {
    
    public var barItem: UIBarButtonItem
    public var callback: () -> Void
    
    public init(
        text: String,
        callback: @escaping () -> Void
    ) {
        self.callback = callback
        self.barItem = UIBarButtonItem(title: text, style: .plain, target: nil, action: nil)
    }
    
    public init(
        image: QImage,
        callback: @escaping () -> Void
    ) {
        self.callback = callback
        self.barItem = UIBarButtonItem(image: image.native, style: .plain, target: nil, action: nil)
    }
    
    public init(
        systemItem: UIBarButtonItem.SystemItem,
        callback: @escaping () -> Void
    ) {
        self.callback = callback
        self.barItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
    }
    
    public func pressed() {
        self.callback()
    }
    
}

public struct QInputToolbarFlexibleSpaceItem : IQInputToolbarItem {
    
    public var barItem: UIBarButtonItem
    
    public init() {
        self.barItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    public func pressed() {
    }
    
}

open class QInputToolbarView : IQInputToolbarView {
    
    public private(set) unowned var parentView: IQView?
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
    public var items: [IQInputToolbarItem] {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(items: self.items)
        }
    }
    public var size: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(size: self.size)
        }
    }
    public var isTranslucent: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(translucent: self.isTranslucent)
        }
    }
    public var barTintColor: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(barTintColor: self.barTintColor)
        }
    }
    public var contentTintColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(contentTintColor: self.contentTintColor)
        }
    }
    public var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    
    private var _reuse: QReuseItem< InputToolbarView >
    private var _view: InputToolbarView {
        return self._reuse.content()
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        reuseBehaviour: QReuseItemBehaviour = .unloadWhenDisappear,
        reuseName: String? = nil,
        items: [IQInputToolbarItem],
        size: Float = 55,
        isTranslucent: Bool = false,
        barTintColor: QColor? = nil,
        contentTintColor: QColor = QColor(rgb: 0xffffff),
        color: QColor? = nil
    ) {
        self.items = items
        self.size = size
        self.isTranslucent = isTranslucent
        self.barTintColor = barTintColor
        self.contentTintColor = contentTintColor
        self.color = color
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
        return QSize(width: available.width, height: self.size)
    }
    
    public func appear(to view: IQView) {
        self.parentView = view
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.disappear()
        self.parentView = nil
        self._onDisappear?()
    }
    
    @discardableResult
    public func items(_ value: [IQInputToolbarItem]) -> Self {
        self.items = value
        return self
    }
    
    @discardableResult
    public func size(available value: Float) -> Self {
        self.size = value
        return self
    }
    
    @discardableResult
    public func translucent(_ value: Bool) -> Self {
        self.isTranslucent = value
        return self
    }
    
    @discardableResult
    public func barTintColor(_ value: QColor?) -> Self {
        self.barTintColor = value
        return self
    }
    
    @discardableResult
    public func contentTintColor(_ value: QColor) -> Self {
        self.contentTintColor = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self.color = value
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

extension QInputToolbarView : InputToolbarViewDelegate {
    
    func pressed(barItem: UIBarButtonItem) {
        guard let item = self.items.first(where: { return $0.barItem == barItem }) else { return }
        item.pressed()
    }
    
}

#endif
