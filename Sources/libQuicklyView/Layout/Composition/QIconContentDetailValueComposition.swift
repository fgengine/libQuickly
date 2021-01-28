//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentDetailValueComposition< IconView: IQView, ContentView: IQView, DetailView: IQView, ValueView: IQView > : IQLayout {
    
    public weak var delegate: IQLayoutDelegate?
    public weak var parentView: IQView?
    public var iconInset: QInset {
        didSet(oldValue) {
            guard self.iconInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var iconView: IconView {
        didSet(oldValue) {
            guard self.iconView !== oldValue else { return }
            self.iconItem = QLayoutItem(view: self.iconView)
            self.setNeedUpdate()
        }
    }
    public private(set) var iconItem: IQLayoutItem
    public var contentInset: QInset {
        didSet(oldValue) {
            guard self.contentInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var contentView: ContentView {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self.contentItem = QLayoutItem(view: self.contentView)
            self.setNeedUpdate()
        }
    }
    public private(set) var contentItem: IQLayoutItem
    public var detailInset: QInset {
        didSet(oldValue) {
            guard self.detailInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var detailView: DetailView {
        didSet(oldValue) {
            guard self.detailView !== oldValue else { return }
            self.detailItem = QLayoutItem(view: self.detailView)
            self.setNeedUpdate()
        }
    }
    public private(set) var detailItem: IQLayoutItem
    public var valueInset: QInset {
        didSet(oldValue) {
            guard self.valueInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var valueView: ValueView {
        didSet(oldValue) {
            guard self.valueView !== oldValue else { return }
            self.valueItem = QLayoutItem(view: self.valueView)
            self.setNeedUpdate()
        }
    }
    public private(set) var valueItem: IQLayoutItem
    
    public init(
        iconInset: QInset = QInset(horizontal: 8, vertical: 4),
        iconView: IconView,
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        detailInset: QInset = QInset(horizontal: 8, vertical: 4),
        detailView: DetailView,
        valueInset: QInset = QInset(horizontal: 8, vertical: 4),
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
    
    public func items(bounds: QRect) -> [IQLayoutItem] {
        let items = [ self.iconItem, self.contentItem, self.detailItem, self.valueItem ]
        return self.visible(items: items, for: bounds)
    }
    
}
