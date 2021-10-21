//
//  libQuicklyLogUI
//

import Foundation
import libQuicklyLog
import libQuicklyObserver

protocol IQLogUITargetObserver : AnyObject {
    
    func append(_ target: QLogUI.Target, item: QLogUI.Target.Item)
    func remove(_ target: QLogUI.Target, item: QLogUI.Target.Item)

}

public extension QLogUI {

    class Target : IQLogTarget {
            
        public var enabled: Bool
        public let limit: Int
        
        public private(set) var items: [Item]
        
        private var _lastIndex: Int
        private let _observer: QObserver< IQLogUITargetObserver >
        
        public init(
            enabled: Bool = true,
            limit: Int = 512
        ) {
            self.enabled = enabled
            self.limit = limit
            self.items = []
            self._lastIndex = 0
            self._observer = QObserver()
        }
        
        public func log(level: QLog.Level, category: String, message: String) {
            guard self.enabled == true else { return }
            let appendItem = Item(index: self._lastIndex, date: Date(), level: level, category: category, message: message)
            self.items.append(appendItem)
            self._lastIndex += 1
            self._observer.notify({ $0.append(self, item: appendItem) })
            if self.items.count > self.limit {
                let removeItem = self.items.removeFirst()
                self._observer.notify({ $0.remove(self, item: removeItem) })
            }
        }

    }

}

public extension QLogUI.Target {
    
    struct Item : Equatable {
        
        public let index: Int
        public let date: Date
        public let level: QLog.Level
        public let category: String
        public let message: String
        
    }
    
}

extension QLogUI.Target {
    
    func add(observer: IQLogUITargetObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    func remove(observer: IQLogUITargetObserver) {
        self._observer.remove(observer)
    }
    
}
