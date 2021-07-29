//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentDetailComposition< ContentView: IQView, DetailView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var contentInset: QInset {
        didSet { self.setNeedUpdate() }
    }
    public var contentView: ContentView {
        didSet {
            self.contentItem = QLayoutItem(view: self.contentView)
            self.setNeedUpdate()
        }
    }
    public private(set) var contentItem: QLayoutItem
    public var detailInset: QInset {
        didSet { self.setNeedUpdate() }
    }
    public var detailView: DetailView {
        didSet {
            self.detailItem = QLayoutItem(view: self.detailView)
            self.setNeedUpdate()
        }
    }
    public private(set) var detailItem: QLayoutItem
    
    private var _cacheContentSize: QSize?
    private var _cacheDetailSize: QSize?
    
    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        detailInset: QInset = QInset(horizontal: 8, vertical: 4),
        detailView: DetailView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.detailInset = detailInset
        self.detailView = detailView
        self.detailItem = QLayoutItem(view: detailView)
    }
    
    public func invalidate(item: QLayoutItem) {
        if self.contentItem === item {
            self._cacheContentSize = nil
        }
        if self.detailItem === item {
            self._cacheDetailSize = nil
        }
    }
    
    public func invalidate() {
        self._cacheContentSize = nil
        self._cacheDetailSize = nil
    }
    
    public func layout(bounds: QRect) -> QSize {
        let contentSize = self._contentSize(bounds.size)
        self.contentItem.frame = QRect(
            x: bounds.origin.x + self.contentInset.left,
            y: bounds.origin.y + self.contentInset.top,
            width: contentSize.width,
            height: contentSize.height
        )
        let detailSize = self._detailSize(QSize(
            width: bounds.size.width,
            height: bounds.size.height - (contentSize.height + self.contentInset.vertical)
        ))
        self.detailItem.frame = QRect(
            x: bounds.origin.x + self.detailInset.left,
            y: bounds.origin.y + self.contentInset.top + contentSize.height + self.contentInset.bottom + self.detailInset.top,
            width: detailSize.width,
            height: detailSize.height
        )
        return QSize(
            width: contentSize.width + self.contentInset.horizontal,
            height: (contentSize.height + self.contentInset.vertical) + (detailSize.height + self.detailInset.vertical)
        )
    }
    
    public func size(_ available: QSize) -> QSize {
        let contentSize, detailSize: QSize
        if available.width.isInfinite == true && available.height.isInfinite == true {
            contentSize = self.contentItem.size(QSize(
                width: .infinity,
                height: .infinity
            ))
            detailSize = self.detailItem.size(QSize(
                width: .infinity,
                height: .infinity
            ))
        } else if available.width.isInfinite == true && available.height.isInfinite == false {
            contentSize = self.contentItem.size(QSize(
                width: .infinity,
                height: available.height - self.contentInset.vertical
            ))
            detailSize = self.detailItem.size(QSize(
                width: .infinity,
                height: available.height - contentSize.height - self.contentInset.vertical - self.detailInset.vertical
            ))
        } else if available.width.isInfinite == false && available.height.isInfinite == true {
            contentSize = self.contentItem.size(QSize(
                width: available.width - self.contentInset.horizontal,
                height: .infinity
            ))
            detailSize = self.detailItem.size(QSize(
                width: available.width - self.detailInset.horizontal,
                height: .infinity
            ))
        } else {
            contentSize = self.contentItem.size(QSize(
                width: available.width - self.contentInset.horizontal,
                height: available.height - self.contentInset.vertical
            ))
            detailSize = self.detailItem.size(QSize(
                width: available.width - self.detailInset.horizontal,
                height: available.height - contentSize.height - self.contentInset.vertical - self.detailInset.vertical
            ))
        }
        return QSize(
            width: max(contentSize.width + self.contentInset.horizontal, detailSize.width + self.detailInset.horizontal),
            height: contentSize.height + self.contentInset.vertical + detailSize.height + self.detailInset.vertical
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem, self.detailItem ]
    }
    
}

private extension QContentDetailComposition {
    
    func _contentSize(_ available: QSize) -> QSize {
        if let cacheContentSize = self._cacheContentSize {
            return cacheContentSize
        }
        self._cacheContentSize = self.contentItem.size(available.apply(inset: self.contentInset))
        return self._cacheContentSize!
    }
    
    func _detailSize(_ available: QSize) -> QSize {
        if let cacheDetailSize = self._cacheDetailSize {
            return cacheDetailSize
        }
        self._cacheDetailSize = self.detailItem.size(available.apply(inset: self.detailInset))
        return self._cacheDetailSize!
    }
    
}
