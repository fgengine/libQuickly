//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QListLayout : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var direction: Direction {
        didSet(oldValue) {
            guard self.direction != oldValue else { return }
            self.invalidate()
            self.setNeedUpdate()
        }
    }
    public var origin: Origin {
        didSet(oldValue) {
            guard self.origin != oldValue else { return }
            self.invalidate()
            self.setNeedUpdate()
        }
    }
    public var alignment: Alignment {
        didSet(oldValue) {
            guard self.alignment != oldValue else { return }
            self.invalidate()
            self.setNeedUpdate()
        }
    }
    public var inset: QInset {
        didSet(oldValue) {
            guard self.inset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var spacing: Float {
        didSet(oldValue) {
            guard self.spacing != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var items: [QLayoutItem] {
        set(value) {
            self._items = value
            self.invalidate()
            self.setNeedUpdate()
        }
        get { return self._items }
    }
    public var views: [IQView] {
        set(value) {
            self._items = value.compactMap({ return QLayoutItem(view: $0) })
            self.invalidate()
            self.setNeedUpdate()
        }
        get { return self._items.compactMap({ $0.view }) }
    }
    public private(set) var isAnimating: Bool
    
    private var _items: [QLayoutItem]
    private var _animations: [Animation]
    private var _operations: [Helper.Operation]
    private var _cache: [QSize?]

    public init(
        direction: Direction,
        origin: Origin = .forward,
        alignment: Alignment = .fill,
        inset: QInset = .zero,
        spacing: Float = 0,
        items: [QLayoutItem] = []
    ) {
        self.direction = direction
        self.origin = origin
        self.alignment = alignment
        self.inset = inset
        self.spacing = spacing
        self.isAnimating = false
        self._items = items
        self._animations = []
        self._operations = []
        self._cache = Array< QSize? >(repeating: nil, count: items.count)
    }

    public convenience init(
        direction: Direction,
        origin: Origin = .forward,
        alignment: Alignment = .fill,
        inset: QInset = .zero,
        spacing: Float = 0,
        views: [IQView]
    ) {
        self.init(
            direction: direction,
            origin: origin,
            alignment: alignment,
            inset: inset,
            spacing: spacing,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func animate(
        duration: TimeInterval,
        ease: IQAnimationEase = QAnimation.Ease.Linear(),
        perform: @escaping (_ layout: QListLayout) -> Void,
        completion: (() -> Void)? = nil
    ) {
        let animation = Animation(duration: duration, ease: ease, perform: perform, completion: completion)
        self._animations.append(animation)
        if self._animations.count == 1 {
            self._animate(animation: animation)
        }
    }
    
    public func insert(index: Int, items: [QLayoutItem]) {
        let safeIndex = max(0, min(index, self._items.count))
        self._items.insert(contentsOf: items, at: safeIndex)
        self._cache.insert(contentsOf: Array< QSize? >(repeating: nil, count: items.count), at: safeIndex)
        if self._animations.isEmpty == false {
            self._operations.append(Helper.Operation(
                type: .insert,
                indices: Set< Int >(range: safeIndex ..< safeIndex + items.count),
                progress: 0
            ))
        } else {
            self.setNeedUpdate()
        }
    }
    
    public func insert(index: Int, views: [IQView]) {
        self.insert(
            index: index,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func delete(range: Range< Int >) {
        if self._animations.isEmpty == false {
            self._operations.append(Helper.Operation(
                type: .delete,
                indices: Set< Int >(range: range),
                progress: 0
            ))
        } else {
            self._items.removeSubrange(range)
            self._cache.removeSubrange(range)
            self.setNeedUpdate()
        }
    }
    
    public func delete(items: [QLayoutItem]) {
        let indices = items.compactMap({ item in self.items.firstIndex(where: { $0 === item }) })
        if indices.count > 0 {
            if self._animations.isEmpty == false {
                self._operations.append(Helper.Operation(
                    type: .delete,
                    indices: Set< Int >(indices),
                    progress: 0
                ))
            } else {
                for index in indices {
                    self._items.remove(at: index)
                    self._cache.remove(at: index)
                }
                self.setNeedUpdate()
            }
        }
    }
    
    public func delete(views: [IQView]) {
        self.delete(
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func index(item: QLayoutItem) -> Int? {
        return self.items.firstIndex(where: { $0 === item })
    }
    
    public func indices(items: [QLayoutItem]) -> [Int] {
        return items.compactMap({ item in self.items.firstIndex(where: { $0 === item }) })
    }
    
    public func invalidate(item: QLayoutItem) {
        if let index = self._items.firstIndex(where: { $0 === item }) {
            self._cache[index] = nil
        }
    }
    
    public func invalidate() {
        guard self.isAnimating == false else { return }
        self._cache = Array< QSize? >(repeating: nil, count: self._items.count)
    }
    
    public func layout(bounds: QRect) -> QSize {
        return Helper.layout(
            bounds: bounds,
            direction: self.direction,
            origin: self.origin,
            alignment: self.alignment,
            inset: self.inset,
            spacing: self.spacing,
            operations: self._operations,
            items: self._items,
            cache: &self._cache
        )
    }
    
    public func size(_ available: QSize) -> QSize {
        return Helper.size(
            available: available,
            direction: self.direction,
            alignment: self.alignment,
            inset: self.inset,
            spacing: self.spacing,
            items: self._items,
            operations: self._operations
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return self.visible(items: self._items, for: bounds)
    }
    
}

public extension QListLayout {
    
    enum Direction {
        case horizontal
        case vertical
    }
    
    enum Origin {
        case forward
        case backward
    }
    
    enum Alignment {
        case leading
        case center
        case trailing
        case fill
    }
    
}

private extension QListLayout {
    
    class Animation {
        
        let duration: TimeInterval
        let ease: IQAnimationEase
        let perform: (_ layout: QListLayout) -> Void
        let completion: (() -> Void)?
        
        public init(
            duration: TimeInterval,
            ease: IQAnimationEase,
            perform: @escaping (_ layout: QListLayout) -> Void,
            completion: (() -> Void)?
        ) {
            self.duration = duration
            self.ease = ease
            self.perform = perform
            self.completion = completion
        }

    }
    
}

private extension QListLayout {
    
    func _animate(animation: Animation) {
        self.isAnimating = true
        animation.perform(self)
        QAnimation.default.run(
            duration: animation.duration,
            ease: animation.ease,
            processing: { [unowned self] progress in
                for operation in self._operations {
                    operation.progress = progress
                }
                self.setNeedUpdate()
                self.updateIfNeeded()
            },
            completion: { [unowned self] in
                for operation in self._operations {
                    switch operation.type {
                    case .delete:
                        for index in operation.indices.reversed() {
                            self._items.remove(at: index)
                            self._cache.remove(at: index)
                        }
                    default:
                        break
                    }
                }
                self.setNeedUpdate()
                self.updateIfNeeded()
                self._operations.removeAll()
                if let index = self._animations.firstIndex(where: { $0 === animation }) {
                    self._animations.remove(at: index)
                }
                if let animation = self._animations.first {
                    self._animate(animation: animation)
                } else {
                    self.isAnimating = false
                }
                animation.completion?()
            }
        )
    }
    
}
