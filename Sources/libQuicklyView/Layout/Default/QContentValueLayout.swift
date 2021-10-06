//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentValueLayout< ContentView: IQView, ValueView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var contentInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var contentView: ContentView {
        didSet { self.contentItem = QLayoutItem(view: self.contentView) }
    }
    public private(set) var contentItem: QLayoutItem {
        didSet { self.setNeedForceUpdate(item: self.contentItem) }
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
        contentInset: QInset,
        contentView: ContentView,
        valueInset: QInset,
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
        let valueSize = self.valueItem.size(available: bounds.size.apply(inset: self.valueInset))
        let contentValue = bounds.split(
            right: self.valueInset.left + valueSize.width + self.valueInset.right
        )
        self.contentItem.frame = contentValue.left.apply(inset: self.contentInset)
        self.valueItem.frame = contentValue.right.apply(inset: self.valueInset)
        return bounds.size
    }
    
    public func size(available: QSize) -> QSize {
        let valueSize = self.valueItem.size(available: available.apply(inset: self.valueInset))
        let valueBounds = valueSize.apply(inset: -self.valueInset)
        let contentAvailable = QSize(
            width: available.width - valueBounds.width,
            height: available.height
        )
        let contentSize = self.contentItem.size(available: contentAvailable.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        return QSize(
            width: contentBounds.width + valueBounds.width,
            height: max(contentBounds.height, valueBounds.height)
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem, self.valueItem ]
    }
    
}
