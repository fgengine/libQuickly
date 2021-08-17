//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QExpandComposition< ContentView: IQView, DetailView: IQView > : IQLayout {
    
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
    public var detailInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var detailView: DetailView {
        didSet { self.detailItem = QLayoutItem(view: self.detailView) }
    }
    public private(set) var detailItem: QLayoutItem {
        didSet { self.setNeedForceUpdate(item: self.detailItem) }
    }
    public var isAnimating: Bool {
        return self._animationTask != nil
    }
    
    private var _contentSize: QSize?
    private var _detailSize: QSize?
    private var _state: State {
        didSet { self.setNeedForceUpdate() }
    }
    private var _animationTask: IQAnimationTask? {
        willSet {
            guard let animationTask = self._animationTask else { return }
            animationTask.cancel()
        }
    }
    
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
        self._state = .collapsed
    }
    
    public func collapse(
        duration: TimeInterval,
        ease: IQAnimationEase = QAnimation.Ease.Linear(),
        completion: (() -> Void)? = nil
    ) {
        self._animationTask = QAnimation.default.run(
            duration: duration,
            ease: ease,
            processing: { [unowned self] progress in
                self._state = .changing(progress: progress)
                self.updateIfNeeded()
            },
            completion: { [unowned self] in
                self._state = .collapsed
                self._animationTask = nil
                self.setNeedForceUpdate()
                self.updateIfNeeded()
                completion?()
            }
        )
    }
    
    public func expand(
        duration: TimeInterval,
        ease: IQAnimationEase = QAnimation.Ease.Linear(),
        completion: (() -> Void)? = nil
    ) {
        self._animationTask = QAnimation.default.run(
            duration: duration,
            ease: ease,
            processing: { [unowned self] progress in
                self._state = .changing(progress: 1 - progress)
                self.updateIfNeeded()
            },
            completion: { [unowned self] in
                self._state = .expanded
                self._animationTask = nil
                self.setNeedForceUpdate()
                self.updateIfNeeded()
                completion?()
            }
        )
    }
    
    public func invalidate(item: QLayoutItem) {
        if self.contentItem === item {
            self._contentSize = nil
        } else if self.detailItem === item {
            self._detailSize = nil
        }
    }
    
    public func layout(bounds: QRect) -> QSize {
        let contentSize: QSize
        if let size = self._contentSize {
            contentSize = size
        } else {
            contentSize = self.contentItem.size(bounds.size.apply(inset: self.contentInset))
            self._contentSize = contentSize
        }
        let detailSize: QSize
        if let size = self._detailSize {
            detailSize = size
        } else {
            detailSize = self.detailItem.size(bounds.size.apply(inset: self.detailInset))
            self._detailSize = detailSize
        }
        switch self._state {
        case .collapsed:
            self.contentItem.frame = QRect(
                x: self.contentInset.left,
                y: self.contentInset.top,
                width: contentSize.width,
                height: contentSize.height
            )
            return QSize(
                width: contentSize.width + self.contentInset.vertical,
                height: contentSize.height + self.contentInset.horizontal
            )
        case .expanded:
            self.contentItem.frame = QRect(
                x: self.contentInset.left,
                y: self.contentInset.top,
                width: contentSize.width,
                height: contentSize.height
            )
            self.detailItem.frame = QRect(
                x: self.detailInset.left,
                y: self.detailInset.top + (self.contentInset.top + contentSize.height + self.contentInset.horizontal),
                width: detailSize.width,
                height: detailSize.height
            )
            return QSize(
                width: max(contentSize.width + self.contentInset.vertical, detailSize.width + self.detailInset.vertical),
                height: (contentSize.height + self.contentInset.horizontal) + (detailSize.height + self.detailInset.horizontal)
            )
        case .changing(let progress):
            self.contentItem.frame = QRect(
                x: self.contentInset.left,
                y: self.contentInset.top,
                width: contentSize.width,
                height: contentSize.height
            )
            self.detailItem.frame = QRect(
                x: self.detailInset.left,
                y: self.detailInset.top + (self.contentInset.top + contentSize.height + self.contentInset.horizontal),
                width: detailSize.width,
                height: detailSize.height
            )
            let collapseDetailHeight: Float = 0
            let expandDetailHeight = (detailSize.height + self.detailInset.horizontal)
            let detailHeight = collapseDetailHeight.lerp(expandDetailHeight, progress: progress)
            return QSize(
                width: max(contentSize.width + self.contentInset.vertical, detailSize.width + self.detailInset.vertical),
                height: (contentSize.height + self.contentInset.horizontal) + detailHeight
            )
        }
    }
    
    public func size(_ available: QSize) -> QSize {
        switch self._state {
        case .collapsed:
            let contentSize = self.contentItem.size(available.apply(inset: self.contentInset)).apply(inset: -self.contentInset)
            return contentSize
        case .expanded:
            let contentSize = self.contentItem.size(available.apply(inset: self.contentInset)).apply(inset: -self.contentInset)
            let detailSize = self.detailItem.size(available.apply(inset: self.detailInset)).apply(inset: -self.detailInset)
            return QSize(
                width: max(contentSize.width, detailSize.width),
                height: contentSize.height + detailSize.height
            )
        case .changing(let progress):
            let contentSize = self.contentItem.size(available.apply(inset: self.contentInset)).apply(inset: -self.contentInset)
            let expandDetailSize = self.detailItem.size(available.apply(inset: self.detailInset)).apply(inset: -self.detailInset)
            let collapseDetailSize = QSize(width: expandDetailSize.width, height: 0)
            let detailSize = collapseDetailSize.lerp(expandDetailSize, progress: progress)
            return QSize(
                width: max(contentSize.width, detailSize.width),
                height: contentSize.height + detailSize.height
            )
        }
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        switch self._state {
        case .collapsed: return [ self.contentItem ]
        case .expanded: return [ self.contentItem, self.detailItem ]
        case .changing: return [ self.contentItem, self.detailItem ]
        }
    }
    
}

private extension QExpandComposition {
    
    enum State {
        case collapsed
        case expanded
        case changing(progress: Float)
    }
    
}
