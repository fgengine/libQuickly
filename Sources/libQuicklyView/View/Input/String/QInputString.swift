//
//  libQuicklyView
//

import Foundation

protocol InputStringViewDelegate : AnyObject {
    
    func beginEditing()
    func editing(text: String)
    func endEditing()
    
}

public class QInputStringView : IQView {
    
    public typealias SimpleClosure = (_ inputStringView: QInputStringView) -> Void
    
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
    public var text: String {
        set(value) {
            self._text = value
            guard self.isLoaded == true else { return }
            self._view.qText = self._text
        }
        get { return self._text }
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
    public var editingColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qEditingColor = self.editingColor
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
    public var keyboard: QInputKeyboard {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qKeyboard = self.keyboard
        }
    }
    #endif
    public var onBeginEditing: SimpleClosure?
    public var onEditing: SimpleClosure
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

    private var _text: String
    private var _view: InputStringView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< InputStringView >

    #if os(iOS)
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        text: String,
        font: QFont,
        color: QColor,
        inset: QInset = QInset(horizontal: 8, vertical: 4),
        editingColor: QColor,
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        alpha: QFloat = 1,
        toolbar: QInputToolbarView? = nil,
        keyboard: QInputKeyboard,
        onBeginEditing: SimpleClosure? = nil,
        onEditing: @escaping SimpleClosure,
        onEndEditing: SimpleClosure? = nil
    ) {
        self.width = width
        self.height = height
        self.font = font
        self.color = color
        self.inset = inset
        self.editingColor = editingColor
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.alpha = alpha
        self.toolbar = toolbar
        self.keyboard = keyboard
        self.onBeginEditing = onBeginEditing
        self.onEditing = onEditing
        self.onEndEditing = onEndEditing
        self._text = text
        self._reuseView = QReuseView()
        toolbar?.delegate = self
    }
    #else
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        text: String,
        font: QFont,
        color: QColor,
        inset: QInset = QInset(horizontal: 8, vertical: 4),
        editingColor: QColor,
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        alpha: QFloat = 1,
        onBeginEditing: SimpleClosure? = nil,
        onEditing: @escaping SimpleClosure,
        onEndEditing: SimpleClosure? = nil
    ) {
        self.width = width
        self.height = height
        self.font = font
        self.color = color
        self.inset = inset
        self.editingColor = editingColor
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.alpha = alpha
        self.onBeginEditing = onBeginEditing
        self.onEditing = onEditing
        self.onEndEditing = onEndEditing
        self._text = text
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
        #if os(iOS)
        self.toolbar?.onAppear(to: self)
        #endif
    }
    
    public func onDisappear() {
        #if os(iOS)
        self.toolbar?.onDisappear()
        #endif
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return available.apply(width: self.width, height: self.height)
    }

}

#if os(iOS)

extension QInputStringView : QInputToolbarDelegate {
    
    public func pressed(_ toolbar: QInputToolbarView, item: IQInputToolbarItem) {
        guard self.toolbar === toolbar else { return }
        if let actionItem = item as? QInputToolbarActionItem< QInputStringView > {
            actionItem.callback(self)
        }
    }
    
}

#endif

extension QInputStringView: InputStringViewDelegate {
    
    func beginEditing() {
        self.onBeginEditing?(self)
    }
    
    func editing(text: String) {
        self._text = text
        self.onEditing(self)
    }
    
    func endEditing() {
        self.onEndEditing?(self)
    }
    
}
