//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentDetailValueLayout< IconView: IQView, ContentView: IQView, DetailView: IQView, ValueView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var iconInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var iconView: IconView {
        didSet { self.iconItem = QLayoutItem(view: self.iconView) }
    }
    public private(set) var iconItem: QLayoutItem {
        didSet { self.setNeedForceUpdate(item: self.iconItem) }
    }
    public var contentInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var contentView: ContentView {
        didSet { self.contentItem = QLayoutItem(view: self.contentView) }
    }
    public private(set) var contentItem: QLayoutItem {
        didSet { self.setNeedForceUpdate(item: self.contentItem) }
    }
    public var detailInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var detailView: DetailView {
        didSet { self.detailItem = QLayoutItem(view: self.detailView) }
    }
    public private(set) var detailItem: QLayoutItem {
        didSet { self.setNeedForceUpdate(item: self.detailItem) }
    }
    public var valueInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var valueView: ValueView {
        didSet { self.valueItem = QLayoutItem(view: self.valueView) }
    }
    public private(set) var valueItem: QLayoutItem {
        didSet { self.setNeedForceUpdate(item: self.valueItem) }
    }
    
    public init(
        iconInset: QInset,
        iconView: IconView,
        contentInset: QInset,
        contentView: ContentView,
        detailInset: QInset,
        detailView: DetailView,
        valueInset: QInset,
        valueView: ValueView
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
        self.valueInset = valueInset
        self.valueView = valueView
        self.valueItem = QLayoutItem(view: valueView)
    }
    
    public func layout(bounds: QRect) -> QSize {
        let iconSize = self.iconItem.size(bounds.size.apply(inset: self.iconInset))
        let valueSize = self.valueItem.size(bounds.size.apply(inset: self.valueInset))
        let iconContentValue = bounds.split(
            left: self.iconInset.left + iconSize.width + self.iconInset.right,
            right: self.valueInset.left + valueSize.width + self.valueInset.right
        )
        let contentSize = self.contentItem.size(iconContentValue.middle.size.apply(inset: self.contentInset))
        let contentDetail = iconContentValue.middle.split(
            top: self.contentInset.top + contentSize.height + self.contentInset.bottom
        )
        self.iconItem.frame = iconContentValue.left.apply(inset: self.iconInset)
        self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
        self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
        self.valueItem.frame = iconContentValue.right.apply(inset: self.valueInset)
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        let iconSize = self.iconItem.size(available.apply(inset: self.iconInset))
        let iconBounds = iconSize.apply(inset: -self.iconInset)
        let valueSize = self.iconItem.size(available.apply(inset: self.valueInset))
        let valueBounds = valueSize.apply(inset: -self.valueInset)
        let contentAvailable = QSize(
            width: available.width - (iconBounds.width + valueBounds.width),
            height: available.height
        )
        let contentSize = self.contentItem.size(contentAvailable.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        let detailSize = self.detailItem.size(contentAvailable.apply(inset: self.detailInset))
        let detailBounds = detailSize.apply(inset: -self.detailInset)
        return QSize(
            width: iconBounds.width + max(contentBounds.width, detailBounds.width) + valueBounds.width,
            height: max(iconBounds.height, contentBounds.height + detailBounds.height, valueBounds.height)
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.iconItem, self.contentItem, self.detailItem, self.valueItem ]
    }
    
}
