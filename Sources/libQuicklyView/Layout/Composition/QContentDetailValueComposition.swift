//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentDetailValueComposition< ContentView: IQView, DetailView: IQView, ValueView: IQView > : IQLayout {
    
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
    public var valueInset: QInset {
        didSet { self.setNeedUpdate() }
    }
    public var valueView: ValueView {
        didSet {
            self.valueItem = QLayoutItem(view: self.valueView)
            self.setNeedUpdate()
        }
    }
    public private(set) var valueItem: QLayoutItem
    
    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        detailInset: QInset = QInset(horizontal: 8, vertical: 4),
        detailView: DetailView,
        valueInset: QInset = QInset(horizontal: 8, vertical: 4),
        valueView: ValueView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.detailInset = detailInset
        self.detailView = detailView
        self.detailItem = QLayoutItem(view: detailView)
        self.valueInset = valueInset
        self.valueView = valueView
        self.valueItem = QLayoutItem(view: valueView)
    }
    
    public func invalidate(item: QLayoutItem) {
    }
    
    public func invalidate() {
    }
    
    public func layout(bounds: QRect) -> QSize {
        let valueSize = self.valueItem.size(bounds.size.apply(inset: self.valueInset))
        let contentDetailValue = bounds.split(
            right: self.valueInset.left + valueSize.width + self.valueInset.right
        )
        let contentSize = self.contentItem.size(contentDetailValue.left.size.apply(inset: self.contentInset))
        let contentDetail = contentDetailValue.left.split(
            top: self.contentInset.top + contentSize.height + self.contentInset.bottom
        )
        self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
        self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
        self.valueItem.frame = contentDetailValue.right.apply(inset: self.valueInset)
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        let valueSize = self.valueItem.size(available.apply(inset: self.valueInset))
        let valueBounds = valueSize.apply(inset: -self.valueInset)
        let contentAvailable = QSize(
            width: available.width - valueBounds.width,
            height: available.height
        )
        let contentSize = self.contentItem.size(contentAvailable.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        let detailSize = self.detailItem.size(contentAvailable.apply(inset: self.detailInset))
        let detailBounds = detailSize.apply(inset: -self.detailInset)
        return QSize(
            width: max(contentBounds.width, detailBounds.width) + valueBounds.width,
            height: max(contentBounds.height + detailBounds.height, valueBounds.height)
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem, self.detailItem, self.valueItem ]
    }
    
}
