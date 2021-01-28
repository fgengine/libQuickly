//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentComposition< IconView: IQView, ContentView: IQView > : IQLayout {
    
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
    
    public func items(bounds: QRect) -> [IQLayoutItem] {
        let items = [ self.iconItem, self.contentItem ]
        return self.visible(items: items, for: bounds)
    }
    
}
