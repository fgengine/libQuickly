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
    public var items: [IQLayoutItem] {
        return [
            self.contentItem
        ]
    }
    public private(set) var size: QSize

    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.size = QSize()
    }
    
    public func layout() {
        var size: QSize
        if let bounds = self.delegate?.bounds(self) {
            size = bounds.size
            self.contentItem.frame = bounds.apply(inset: self.contentInset)
        } else {
            size = QSize()
        }
        self.size = size
    }
    
    public func size(_ available: QSize) -> QSize {
        let contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        return contentBounds
    }
    
}
