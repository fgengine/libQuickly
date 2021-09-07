//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentDetailLayout< IconView: IQView, ContentView: IQView, DetailView: IQView > : IQLayout {
    
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
    
    public init(
        iconInset: QInset,
        iconView: IconView,
        contentInset: QInset,
        contentView: ContentView,
        detailInset: QInset,
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
        let size = QSize(
            width: bounds.width,
            height: .infinity
        )
        let iconSize = self.iconItem.size(QSize(
            width: size.width - self.iconInset.horizontal,
            height: .infinity
        ))
        let contentSize = self.contentItem.size(QSize(
            width: size.width - self.contentInset.horizontal - iconSize.width - self.iconInset.horizontal,
            height: .infinity
        ))
        let detailSize = self.detailItem.size(QSize(
            width: size.width - self.detailInset.horizontal - iconSize.width - self.iconInset.horizontal,
            height: .infinity
        ))
        let splitFrames = QRect(
            x: bounds.x,
            y: bounds.y,
            width: size.width,
            height: max(iconSize.height + self.iconInset.vertical, contentSize.height + self.contentInset.vertical + detailSize.height + self.detailInset.vertical)
        ).split(
            left: iconSize.width + self.iconInset.left
        )
        self.iconItem.frame = QRect(
            center: splitFrames.left.apply(inset: self.iconInset).center,
            size: iconSize
        )
        self.contentItem.frame = QRect(
            x: splitFrames.right.x + self.contentInset.left,
            y: splitFrames.right.y + self.contentInset.top,
            width: contentSize.width,
            height: contentSize.height
        )
        self.detailItem.frame = QRect(
            x: splitFrames.right.x + self.detailInset.left,
            y: splitFrames.right.y + self.contentInset.vertical + contentSize.height + self.detailInset.top,
            width: detailSize.width,
            height: detailSize.height
        )
        return QSize(
            width: bounds.width,
            height: max(iconSize.height + self.iconInset.vertical, contentSize.height + self.contentInset.vertical + detailSize.height + self.detailInset.vertical)
        )
    }
    
    public func size(_ available: QSize) -> QSize {
        let size = QSize(
            width: available.width,
            height: .infinity
        )
        let iconSize = self.iconItem.size(QSize(
            width: size.width - self.iconInset.horizontal,
            height: .infinity
        ))
        let contentSize = self.contentItem.size(QSize(
            width: size.width - self.contentInset.horizontal - iconSize.width - self.iconInset.horizontal,
            height: .infinity
        ))
        let detailSize = self.detailItem.size(QSize(
            width: size.width - self.detailInset.horizontal - iconSize.width - self.iconInset.horizontal,
            height: .infinity
        ))
        return QSize(
            width: available.width,
            height: max(iconSize.height + self.iconInset.vertical, contentSize.height + self.contentInset.vertical + detailSize.height + self.detailInset.vertical)
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.iconItem, self.contentItem, self.detailItem ]
    }
    
}
