//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentComposition< ContentView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
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
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
    }
    
    public func invalidate(item: QLayoutItem) {
    }
    
    public func invalidate() {
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
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem ]
    }
    
}
