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
            self._firstVisible = nil
            self.setNeedForceUpdate()
        }
    }
    public var alignment: Alignment {
        didSet(oldValue) {
            guard self.alignment != oldValue else { return }
            self.setNeedForceUpdate()
        }
    }
    public var inset: QInset {
        didSet(oldValue) {
            guard self.inset != oldValue else { return }
            self.setNeedForceUpdate()
        }
    }
    public var spacing: Float {
        didSet(oldValue) {
            guard self.spacing != oldValue else { return }
            self.setNeedForceUpdate()
        }
    }
    public var items: [QLayoutItem] {
        set(value) {
            self._items = value
            self._cache = Array< QSize? >(repeating: nil, count: value.count)
            self._firstVisible = nil
            self.setNeedForceUpdate()
        }
        get { return self._items }
    }
    public var views: [IQView] {
        set(value) {
            self._items = value.compactMap({ return QLayoutItem(view: $0) })
            self._cache = Array< QSize? >(repeating: nil, count: value.count)
            self._firstVisible = nil
            self.setNeedForceUpdate()
        }
        get { return self._items.compactMap({ $0.view }) }
    }
    public private(set) var isAnimating: Bool
    
    private var _items: [QLayoutItem]
    private var _animations: [Animation]
    private var _operations: [Helper.Operation]
    private var _cache: [QSize?]
    private var _firstVisible: Int?

    public init(
        direction: Direction,
        alignment: Alignment = .fill,
        inset: QInset = .zero,
        spacing: Float = 0,
        items: [QLayoutItem] = []
    ) {
        self.direction = direction
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
        alignment: Alignment = .fill,
        inset: QInset = .zero,
        spacing: Float = 0,
        views: [IQView]
    ) {
        self.init(
            direction: direction,
            alignment: alignment,
            inset: inset,
            spacing: spacing,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func contains(view: IQView) -> Bool {
        guard let item = view.item else { return false }
        return self.contains(item: item)
    }
    
    public func contains(item: QLayoutItem) -> Bool {
        return self.items.contains(where: { $0 === item })
    }
    
    public func index(view: IQView) -> Int? {
        guard let item = view.item else { return nil }
        return self.index(item: item)
    }
    
    public func index(item: QLayoutItem) -> Int? {
        return self.items.firstIndex(where: { $0 === item })
    }
    
    public func indices(items: [QLayoutItem]) -> [Int] {
        return items.compactMap({ item in self.items.firstIndex(where: { $0 === item }) })
    }
    
    public func animate(
        delay: TimeInterval = 0,
        duration: TimeInterval,
        ease: IQAnimationEase = QAnimation.Ease.Linear(),
        perform: @escaping (_ layout: QListLayout) -> Void,
        completion: (() -> Void)? = nil
    ) {
        let animation = Animation(delay: delay, duration: duration, ease: ease, perform: perform, completion: completion)
        self._animations.append(animation)
        if self._animations.count == 1 {
            self._animate(animation: animation)
        }
    }
    
    public func insert(index: Int, items: [QLayoutItem]) {
        let safeIndex = max(0, min(index, self._items.count))
        self._items.insert(contentsOf: items, at: safeIndex)
        self._cache.insert(contentsOf: Array< QSize? >(repeating: nil, count: items.count), at: safeIndex)
        self._firstVisible = nil
        if self._animations.isEmpty == false {
            self._operations.append(Helper.Operation(
                type: .insert,
                indices: Set< Int >(range: safeIndex ..< safeIndex + items.count),
                progress: 0
            ))
        } else {
            self.setNeedForceUpdate()
        }
    }
    
    public func insert(index: Int, views: [IQView]) {
        self.insert(
            index: index,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func delete(range: Range< Int >) {
        self._firstVisible = nil
        if self._animations.isEmpty == false {
            self._operations.append(Helper.Operation(
                type: .delete,
                indices: Set< Int >(range: range),
                progress: 0
            ))
        } else {
            self._items.removeSubrange(range)
            self._cache.removeSubrange(range)
            self.setNeedForceUpdate()
        }
    }
    
    public func delete(items: [QLayoutItem]) {
        let indices = items.compactMap({ item in self.items.firstIndex(where: { $0 === item }) }).sorted()
        if indices.count > 0 {
            self._firstVisible = nil
            if self._animations.isEmpty == false {
                self._operations.append(Helper.Operation(
                    type: .delete,
                    indices: Set< Int >(indices),
                    progress: 0
                ))
            } else {
                for index in indices.reversed() {
                    self._items.remove(at: index)
                    self._cache.remove(at: index)
                }
                self.setNeedForceUpdate()
            }
        }
    }
    
    public func delete(views: [IQView]) {
        self.delete(
            items: views.compactMap({ return $0.item })
        )
    }
    
    public func invalidate(item: QLayoutItem) {
        if let index = self._items.firstIndex(where: { $0 === item }) {
            self._cache[index] = nil
        }
    }
    
    public func layout(bounds: QRect) -> QSize {
        return Helper.layout(
            bounds: bounds,
            direction: self.direction,
            alignment: self.alignment,
            inset: self.inset,
            spacing: self.spacing,
            operations: self._operations,
            items: self._items,
            cache: &self._cache
        )
    }
    
    public func size(available: QSize) -> QSize {
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
        guard let firstVisible = self._visibleIndex(bounds: bounds) else {
            return []
        }
        var result: [QLayoutItem] = [ self._items[firstVisible] ]
        let start = min(firstVisible + 1, self._items.count)
        let end = self._items.count
        for index in start ..< end {
            let item = self._items[index]
            if bounds.isIntersects(rect: item.frame) == true {
                result.append(item)
            } else {
                break
            }
        }
        return result
    }
    
}

public extension QListLayout {
    
    enum Direction {
        case horizontal
        case vertical
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
        
        let delay: TimeInterval
        let duration: TimeInterval
        let ease: IQAnimationEase
        let perform: (_ layout: QListLayout) -> Void
        let completion: (() -> Void)?
        
        public init(
            delay: TimeInterval,
            duration: TimeInterval,
            ease: IQAnimationEase,
            perform: @escaping (_ layout: QListLayout) -> Void,
            completion: (() -> Void)?
        ) {
            self.delay = delay
            self.duration = duration
            self.ease = ease
            self.perform = perform
            self.completion = completion
        }

    }
    
}

private extension QListLayout {
    
    @inline(__always)
    func _visibleIndex(bounds: QRect) -> Int? {
        if let firstVisible = self._firstVisible {
            var newFirstIndex = firstVisible
            let firstItem = self._items[firstVisible]
            let isFirstVisible = bounds.isIntersects(rect: firstItem.frame)
            let isBefore: Bool
            let isAfter: Bool
            switch self.direction {
            case .horizontal:
                isBefore = firstItem.frame.origin.x > bounds.origin.x
                isAfter = firstItem.frame.origin.x < bounds.origin.x
            case .vertical:
                isBefore = firstItem.frame.origin.y > bounds.origin.y
                isAfter = firstItem.frame.origin.y < bounds.origin.y
            }
            if isBefore == true {
                var isFounded = isFirstVisible
                for index in (0 ..< firstVisible + 1).reversed() {
                    let item = self._items[index]
                    if bounds.isIntersects(rect: item.frame) == true {
                        newFirstIndex = index
                        isFounded = true
                    } else if isFounded == true {
                        break
                    }
                }
            } else if isAfter == true {
                for index in firstVisible ..< self._items.count {
                    let item = self._items[index]
                    if bounds.isIntersects(rect: item.frame) == true {
                        newFirstIndex = index
                        break
                    }
                }
            }
            self._firstVisible = newFirstIndex
            return newFirstIndex
        }
        for index in 0 ..< self._items.count {
            let item = self._items[index]
            if bounds.isIntersects(rect: item.frame) == true {
                self._firstVisible = index
                return index
            }
        }
        return nil
    }
    
    func _animate(animation: Animation) {
        self.isAnimating = true
        animation.perform(self)
        QAnimation.default.run(
            delay: animation.delay,
            duration: animation.duration,
            ease: animation.ease,
            processing: { [unowned self] progress in
                for operation in self._operations {
                    operation.progress = progress
                }
                self.setNeedForceUpdate()
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
                self.setNeedForceUpdate()
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
