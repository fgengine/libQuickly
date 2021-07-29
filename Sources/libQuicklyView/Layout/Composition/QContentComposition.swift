//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentComposition< ContentView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var contentInset: QInset {
        didSet { self.setNeedUpdate() }
    }
    public var contentView: ContentView {
        didSet { self.contentItem = QLayoutItem(view: self.contentView) }
    }
    public private(set) var contentItem: QLayoutItem {
        didSet { self.setNeedUpdate() }
    }
    
    private var _cacheContentSize: QSize?

    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
    }
    
    public func invalidate(item: QLayoutItem) {
        if self.contentItem === item {
            self._cacheContentSize = nil
        }
    }
    
    public func invalidate() {
        self._cacheContentSize = nil
    }
    
    public func layout(bounds: QRect) -> QSize {
        let contentSize = self._contentSize(bounds.size)
        self.contentItem.frame = QRect(
            x: bounds.origin.x + self.contentInset.left,
            y: bounds.origin.y + self.contentInset.top,
            width: contentSize.width,
            height: contentSize.height
        )
        return QSize(
            width: contentSize.width + self.contentInset.horizontal,
            height: contentSize.height + self.contentInset.vertical
        )
    }
    
    public func size(_ available: QSize) -> QSize {
        let contentSize: QSize
        if available.width.isInfinite == true && available.height.isInfinite == true {
            contentSize = self.contentItem.size(QSize(
                width: .infinity,
                height: .infinity
            ))
        } else if available.width.isInfinite == true && available.height.isInfinite == false {
            contentSize = self.contentItem.size(QSize(
                width: .infinity,
                height: available.height - self.contentInset.vertical
            ))
        } else if available.width.isInfinite == false && available.height.isInfinite == true {
            contentSize = self.contentItem.size(QSize(
                width: available.width - self.contentInset.horizontal,
                height: .infinity
            ))
        } else {
            contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
        }
        return contentSize.apply(inset: self.contentInset)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem ]
    }
    
}

private extension QContentComposition {
    
    func _contentSize(_ available: QSize) -> QSize {
        if let cacheContentSize = self._cacheContentSize {
            return cacheContentSize
        }
        self._cacheContentSize = self.contentItem.size(available.apply(inset: self.contentInset))
        return self._cacheContentSize!
    }
    
}
