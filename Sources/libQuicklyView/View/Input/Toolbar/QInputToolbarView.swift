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
    public private(set) var name: String
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuse.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.isAppeared
    }
    public var bounds: QRect {
        guard self.isLoaded == true else { return QRect() }
        return QRect(self._view.bounds)
    }
    public private(set) var items: [IQInputToolbarItem] {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(items: self.items)
        }
    }
    public private(set) var size: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(size: self.size)
        }
    }
    public private(set) var isTranslucent: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(translucent: self.isTranslucent)
        }
    }
    public private(set) var tintColor: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(tintColor: self.tintColor)
        }
    }
    public private(set) var contentTintColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(contentTintColor: self.contentTintColor)
        }
    }
    public private(set) var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    
    private var _reuse: QReuseItem< InputToolbarView >
    private var _view: InputToolbarView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    
    public init(
        name: String? = nil,
        items: [IQInputToolbarItem],
        size: QFloat = 55,
        isTranslucent: Bool = false,
        tintColor: QColor? = nil,
        contentTintColor: QColor = QColor(rgb: 0xffffff),
        color: QColor? = nil
    ) {
        self.name = name ?? String(describing: Self.self)
        self.items = items
        self.size = size
        self.isTranslucent = isTranslucent
        self.tintColor = tintColor
        self.contentTintColor = contentTintColor
        self.color = color
        self._reuse = QReuseItem()
    }
    
    public func size(_ available: QSize) -> QSize {
        return QSize(width: available.width, height: self.size)
    }
    
    public func appear(to view: IQView) {
        self.parentView = view
        self._onAppear?()
    }
    
    public func disappear() {
        self._reuse.unload(owner: self)
        self.parentView = nil
        self._onDisappear?()
    }
    
    @discardableResult
    public func items(_ value: [IQInputToolbarItem]) -> Self {
        self.items = value
        return self
    }
    
    @discardableResult
    public func size(_ value: QFloat) -> Self {
        self.size = value
        return self
    }
    
    @discardableResult
    public func translucent(_ value: Bool) -> Self {
        self.isTranslucent = value
        return self
    }
    
    @discardableResult
    public func tintColor(_ value: QColor?) -> Self {
        self.tintColor = value
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
