//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentLayout< IconView: IQView, ContentView: IQView > : IQLayout {
    
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
    
    public init(
        iconInset: QInset,
        iconView: IconView,
        contentInset: QInset,
        contentView: ContentView
    ) {
        self.iconInset = iconInset
        self.iconView = iconView
        self.iconItem = QLayoutItem(view: iconView)
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
    }
    
    public func layout(bounds: QRect) -> QSize {
        let iconSize = self.iconItem.size(bounds.size.apply(inset: self.iconInset))
        let contentValue = bounds.split(
            left: self.iconInset.left + iconSize.width + self.iconInset.right
        )
        self.iconItem.frame = contentValue.left.apply(inset: self.iconInset)
        self.contentItem.frame = contentValue.right.apply(inset: self.contentInset)
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
        return QSize(
            width: iconBounds.width + contentBounds.width,
            height: max(iconBounds.height, contentBounds.height)
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.iconItem, self.contentItem ]
    }
    
}
