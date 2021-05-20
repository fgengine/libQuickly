//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentComposition< IconView: IQView, ContentView: IQView > : IQLayout {
    
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
    
    public init(
        iconInset: QInset = QInset(horizontal: 8, vertical: 4),
        iconView: IconView,
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView
    ) {
        self.iconInset = iconInset
        self.iconView = iconView
        self.iconItem = QLayoutItem(view: iconView)
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
    }
    
    public func invalidate(item: QLayoutItem) {
    }
    
    public func invalidate() {
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
