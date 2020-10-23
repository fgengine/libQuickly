//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public protocol QInputToolbarItem {
    
    var barItem: UIBarButtonItem { get }
    
}

public struct QInputToolbarSpaceItem : QInputToolbarItem {
    
    public var barItem: UIBarButtonItem
    
    public init() {
        self.barItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}

public protocol QInputToolbarDelegate : AnyObject {
    
    func pressed(_ toolbar: QInputToolbarView, item: QInputToolbarItem)
    
}

public class QInputToolbarView : IQAccessoryView {
    
    public private(set) weak var parentView: IQView?
    public weak var delegate: QInputToolbarDelegate?
    public var size: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qSize = self.size
        }
    }
    public var items: [QInputToolbarItem] {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qItems = self.items
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var isTranslucent: Bool {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qIsTranslucent = self.isTranslucent
        }
    }
    public var tintColor: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qTintColor = self.tintColor
        }
    }
    public var contentTintColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qContentTintColor = self.contentTintColor
        }
    }
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
    
    private var _view: InputToolbarView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< InputToolbarView >
    
    public init(
        size: QFloat = 55,
        items: [QInputToolbarItem],
        alpha: QFloat = 1,
        isTranslucent: Bool = false,
        tintColor: QColor? = nil,
        contentTintColor: QColor = QColor(.systemBlue)
    ) {
        self.size = size
        self.items = items
        self.alpha = alpha
        self.isTranslucent = isTranslucent
        self.tintColor = tintColor
        self.contentTintColor = contentTintColor
        self._reuseView = QReuseView()
    }
    
    public func onAppear(to view: IQView) {
        self.parentView = view
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentView = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return QSize(
            width: available.width,
            height: self.size
        )
    }
    
}

protocol InputToolbarViewDelegate : AnyObject {
    
    func pressed(barItem: UIBarButtonItem)
    
}

extension QInputToolbarView : InputToolbarViewDelegate {
    
    func pressed(barItem: UIBarButtonItem) {
        guard let item = self.items.first(where: { return $0.barItem == barItem }) else { return }
        self.delegate?.pressed(self, item: item)
    }
    
}

#endif
