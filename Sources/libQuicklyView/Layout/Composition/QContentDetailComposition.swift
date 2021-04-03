//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QContentDetailComposition< ContentView: IQView, DetailView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var parentView: IQView?
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
    public private(set) var contentItem: QLayoutItem
    public var detailInset: QInset {
        didSet(oldValue) {
            guard self.detailInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var detailView: DetailView {
        didSet(oldValue) {
            guard self.detailView !== oldValue else { return }
            self.detailItem = QLayoutItem(view: self.detailView)
            self.setNeedUpdate()
        }
    }
    public private(set) var detailItem: QLayoutItem
    
    public init(
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: ContentView,
        detailInset: QInset = QInset(horizontal: 8, vertical: 4),
        detailView: DetailView
    ) {
        self.contentInset = contentInset
        self.contentView = contentView
        self.contentItem = QLayoutItem(view: contentView)
        self.detailInset = detailInset
        self.detailView = detailView
        self.detailItem = QLayoutItem(view: detailView)
    }
    
    public func invalidate() {
    }
    
    public func layout(bounds: QRect) -> QSize {
        let contentSize = self.contentItem.size(bounds.size.apply(inset: self.contentInset))
        let contentDetail = bounds.split(
            top: self.contentInset.top + contentSize.height + self.contentInset.bottom
        )
        self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
        self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        let contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
        let contentBounds = contentSize.apply(inset: -self.contentInset)
        let detailSize = self.detailItem.size(available.apply(inset: self.detailInset))
        let detailBounds = detailSize.apply(inset: -self.detailInset)
        return QSize(
            width: max(contentBounds.width, detailBounds.width),
            height: contentBounds.height + detailBounds.height
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return [ self.contentItem, self.detailItem ]
    }
    
}
