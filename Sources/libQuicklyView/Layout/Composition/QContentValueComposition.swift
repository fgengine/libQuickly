//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentValueComposition< ContentView: IQView, ValueView: IQView > : IQLayout {
    
    public weak var delegate: IQLayoutDelegate?
    public weak var parentView: IQView?
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
    
    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        valueInset: QInset = QInset(horizontal: 8, vertical: 4),
        valueView: ValueView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.valueInset = valueInset
        self.valueView = valueView
        self.valueItem = QLayoutItem(view: valueView)
    }
    
    public func layout(bounds: QRect) -> QSize {
        let valueSize = self.valueItem.size(bounds.size.apply(inset: self.valueInset))
        let contentValue = bounds.split(
            right: self.valueInset.left + valueSize.width + self.valueInset.right
        )
        self.contentItem.frame = contentValue.left.apply(inset: self.contentInset)
        self.valueItem.frame = contentValue.right.apply(inset: self.valueInset)
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
        return QSize(
            width: contentBounds.width + valueBounds.width,
            height: max(contentBounds.height, valueBounds.height)
        )
    }
    
    public func items(bounds: QRect) -> [IQLayoutItem] {
        let items = [ self.contentItem, self.valueItem ]
        return self.visible(items: items, for: bounds)
    }
    
}
