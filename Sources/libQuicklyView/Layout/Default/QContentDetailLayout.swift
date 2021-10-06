//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentDetailLayout< ContentView: IQView, DetailView: IQView > : IQLayout {
    
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
    public var detailInset: QInset {
        didSet { self.setNeedUpdate() }
    }
    public var detailView: DetailView {
        didSet {
            self.detailItem = QLayoutItem(view: self.detailView)
            self.setNeedUpdate()
        }
    }
    public private(set) var detailItem: QLayoutItem
    
    public init(
        contentInset: QInset,
        contentView: ContentView,
        detailInset: QInset,
        detailView: DetailView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.detailInset = detailInset
        self.detailView = detailView
        self.detailItem = QLayoutItem(view: detailView)
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
        let detailSize = self.detailItem.size(available: QSize(
            width: size.width - self.detailInset.horizontal,
            height: .infinity
        ))
        self.contentItem.frame = QRect(
            x: bounds.x + self.contentInset.left,
            y: bounds.y + self.contentInset.top,
            width: contentSize.width,
            height: contentSize.height
        )
        self.detailItem.frame = QRect(
            x: bounds.x + self.detailInset.left,
            y: bounds.y + self.contentInset.vertical + contentSize.height + self.detailInset.top,
            width: detailSize.width,
            height: detailSize.height
        )
        return QSize(
            width: bounds.width,
            height: contentSize.height + self.contentInset.vertical + detailSize.height + self.detailInset.vertical
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
        let detailSize = self.detailItem.size(available: QSize(
            width: size.width - self.detailInset.horizontal,
            height: .infinity
        ))
        return QSize(
            width: available.width,
            height: contentSize.height + self.contentInset.vertical + detailSize.height + self.detailInset.vertical
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem, self.detailItem ]
    }
    
}
