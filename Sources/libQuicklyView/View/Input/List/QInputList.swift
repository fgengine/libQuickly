//
//  libQuicklyView
//

import Foundation

protocol InputListViewDelegate : AnyObject {
    
    func beginEditing()
    func select(item: QInputListView.Item)
    func endEditing()
    
}

public class QInputListView : IQView {
    
    public typealias SimpleClosure = (_ inputListView: QInputListView) -> Void
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var items: [Item] {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qItems = self.items
        }
    }
    public var selectedItem: Item? {
        set(value) {
            self._selectedItem = value
            guard self.isLoaded == true else { return }
            self._view.qSelectedItem = self._selectedItem
        }
        get { return self._selectedItem }
    }
    public var font: QFont {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qFont = self.font
        }
    }
    public var color: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColor = self.color
        }
    }
    public var inset: QInset {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qInset = self.inset
        }
    }
    public var placeholder: QInputPlaceholder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qPlaceholder = self.placeholder
        }
    }
    public var placeholderInset: QInset? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qPlaceholderInset = self.placeholderInset
        }
    }
    public var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlignment = self.alignment
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    #if os(iOS)
    public var toolbar: QInputToolbarView? {
        didSet {
            self.toolbar?.delegate = self
            guard self.isLoaded == true else { return }
            self._view.qToolbar = self.toolbar
        }
    }
    #endif
    public var onBeginEditing: SimpleClosure?
    public var onSelected: SimpleClosure
    public var onEndEditing: SimpleClosure?
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.qIsAppeared
    }
    public var native: QNativeView {
        return self._view
    }
    
    private var _selectedItem: Item?
    private var _view: InputListView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< InputListView >
    
    #if os(iOS)
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        items: [Item],
        selectedItem: Item? = nil,
        font: QFont,
        color: QColor,
        inset: QInset = QInset(horizontal: 8, vertical: 4),
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        alpha: QFloat = 1,
        toolbar: QInputToolbarView? = nil,
        onBeginEditing: SimpleClosure? = nil,
        onSelected: @escaping SimpleClosure,
        onEndEditing: SimpleClosure? = nil
    ) {
        self.width = width
        self.height = height
        self.items = items
        self._selectedItem = selectedItem
        self.font = font
        self.color = color
        self.inset = inset
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.alpha = alpha
        self.toolbar = toolbar
        self.onBeginEditing = onBeginEditing
        self.onSelected = onSelected
        self.onEndEditing = onEndEditing
        self._reuseView = QReuseView()
        toolbar?.delegate = self
    }
    #else
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        items: [Item],
        selectedItem: Item? = nil,
        font: QFont,
        color: QColor,
        inset: QInset = QInset(horizontal: 8, vertical: 4),
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        alpha: QFloat = 1,
        onBeginEditing: SimpleClosure? = nil,
        onSelected: @escaping SimpleClosure,
        onEndEditing: SimpleClosure? = nil
    ) {
        self.width = width
        self.height = height
        self.items = items
        self._selectedItem = selectedItem
        self.font = font
        self.color = color
        self.inset = inset
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.alpha = alpha
        self.onBeginEditing = onBeginEditing
        self.onSelected = onSelected
        self.onEndEditing = onEndEditing
        self._reuseView = QReuseView()
    }
    #endif
    
    deinit {
        #if os(iOS)
        self.toolbar?.delegate = nil
        #endif
    }
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return available.apply(width: self.width, height: self.height)
    }

}

public extension QInputListView {
    
    class Item {
        
        public var title: String
        
        public init(
            title: String
        ) {
            self.title = title
        }
        
    }
    
    class ValueItem< Value > : Item {
        
        public var value: Value
        
        public init(
            title: String,
            value: Value
        ) {
            self.value = value
            super.init(
                title: title
            )
        }
        
    }
    
}

#if os(iOS)

extension QInputListView : QInputToolbarDelegate {
    
    public func pressed(_ toolbar: QInputToolbarView, item: IQInputToolbarItem) {
        guard self.toolbar === toolbar else { return }
        if let actionItem = item as? QInputToolbarActionItem< QInputListView > {
            actionItem.callback(self)
        }
    }
    
}

#endif

extension QInputListView: InputListViewDelegate {
    
    func beginEditing() {
        self.onBeginEditing?(self)
    }
    
    func select(item: QInputListView.Item) {
        self._selectedItem = item
        self.onSelected(self)
    }
    
    func endEditing() {
        self.onEndEditing?(self)
    }
    
}
