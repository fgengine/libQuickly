//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QIconContentValueComposition< IconView: IQView, ContentView: IQView, ValueView: IQView > : IQLayout {
    
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
    public var items: [IQLayoutItem] {
        return [
            self.iconItem,
            self.contentItem,
            self.valueItem
        ]
    }
    public private(set) var size: QSize
    
    public init(
        iconInset: QInset = QInset(horizontal: 8, vertical: 4),
        iconView: IconView,
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        valueInset: QInset = QInset(horizontal: 8, vertical: 4),
        valueView: ValueView
    ) {
        self.iconInset = iconInset
        self.iconView = iconView
        self.iconItem = QLayoutItem(view: iconView)
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.valueInset = valueInset
        self.valueView = valueView
        self.valueItem = QLayoutItem(view: valueView)
        self.size = QSize()
    }
    
    public func layout() {
        var size: QSize
        if let bounds = self.delegate?.bounds(self) {
            size = bounds.size
            let iconSize = self.iconItem.size(bounds.size.apply(inset: self.iconInset))
            let valueSize = self.valueItem.size(bounds.size.apply(inset: self.valueInset))
            let iconContentValue = bounds.split(
                left: self.iconInset.left + iconSize.width + self.iconInset.right,
                right: self.valueInset.left + valueSize.width + self.valueInset.right
            )
            self.iconItem.frame = iconContentValue.left.apply(inset: self.iconInset)
            self.contentItem.frame = iconContentValue.middle.apply(inset: self.contentInset)
            self.valueItem.frame = iconContentValue.right.apply(inset: self.valueInset)
        } else {
            size = QSize()
        }
        self.size = size
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
        return QSize(
            width: iconBounds.width + contentBounds.width + valueBounds.width,
            height: max(iconBounds.height, contentBounds.height, valueBounds.height)
        )
    }
    
}
