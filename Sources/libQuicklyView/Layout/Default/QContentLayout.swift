//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentLayout< ContentView: IQView > : IQLayout {
    
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

    public init(
        contentInset: QInset,
        contentView: ContentView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
    }
    
    public func layout(bounds: QRect) -> QSize {
        let size = QSize(
            width: bounds.width,
            height: .infinity
        )
        let contentSize = self.contentItem.size(available: QSize(
            width: size.width - self.contentInset.horizontal,
            height: .infinity
        ))
        self.contentItem.frame = QRect(
            x: bounds.origin.x + self.contentInset.left,
            y: bounds.origin.y + self.contentInset.top,
            width: contentSize.width,
            height: contentSize.height
        )
        return QSize(
            width: bounds.width,
            height: contentSize.height + self.contentInset.vertical
        )
    }
    
    public func size(available: QSize) -> QSize {
        let size = QSize(
            width: available.width,
            height: .infinity
        )
        let contentSize = self.contentItem.size(available: QSize(
            width: size.width - self.contentInset.horizontal,
            height: .infinity
        ))
        return QSize(
            width: available.width,
            height: contentSize.height + self.contentInset.vertical
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem ]
    }
    
}
