//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentDetailComposition< IconView: IQView, ContentView: IQView, DetailView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var iconInset: QInset {
        didSet { self.setNeedUpdate() }
    }
    public var iconView: IconView {
        didSet {
            self.iconItem = QLayoutItem(view: self.iconView)
            self.setNeedUpdate()
        }
    }
    public private(set) var iconItem: QLayoutItem
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
    
    public init(
        iconInset: QInset = QInset(horizontal: 8, vertical: 4),
        iconView: IconView,
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        detailInset: QInset = QInset(horizontal: 8, vertical: 4),
        detailView: DetailView
    ) {
        self.iconInset = iconInset
        self.iconView = iconView
        self.iconItem = QLayoutItem(view: iconView)
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.detailInset = detailInset
        self.detailView = detailView
        self.detailItem = QLayoutItem(view: detailView)
    }
    
    public func layout(bounds: QRect) -> QSize {
        let iconSize = self.iconItem.size(bounds.size.apply(inset: self.iconInset))
        let contentDetailValue = bounds.split(
            left: self.iconInset.left + iconSize.width + self.iconInset.right
        )
        let contentSize = self.contentItem.size(contentDetailValue.right.size.apply(inset: self.contentInset))
        let contentDetail = contentDetailValue.right.split(
            top: self.contentInset.top + contentSize.height + self.contentInset.bottom
        )
        self.iconItem.frame = contentDetailValue.left.apply(inset: self.iconInset)
        self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
        self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        let iconSize = self.iconItem.size(available.apply(inset: self.iconInset))
        let iconBounds = iconSize.apply(inset: -self.iconInset)
        let contentAvailable = QSize(
            width: available.width - iconBounds.width,
            height: available.height
        )
        let contentSize = self.contentItem.size(contentAvailable.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        let detailSize = self.detailItem.size(contentAvailable.apply(inset: self.detailInset))
        let detailBounds = detailSize.apply(inset: -self.detailInset)
        return QSize(
            width: iconBounds.width + max(contentBounds.width, detailBounds.width),
            height: max(iconBounds.height, contentBounds.height + detailBounds.height)
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.iconItem, self.contentItem, self.detailItem ]
    }
    
}
