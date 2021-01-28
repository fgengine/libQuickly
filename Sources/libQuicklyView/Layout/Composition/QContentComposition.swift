//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentComposition< ContentView: IQView > : IQLayout {
    
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

    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
    }
    
    public func layout(bounds: QRect) -> QSize {
        self.contentItem.frame = bounds.apply(inset: self.contentInset)
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        let contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        return contentBounds
    }
    
    public func items(bounds: QRect) -> [IQLayoutItem] {
        let items = [ self.contentItem ]
        return self.visible(items: items, for: bounds)
    }
    
}
