//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import TPInAppReceipt
import libQuicklyCore
import libQuicklyObserver

public protocol IQInAppSubscriptionControllerObserver : AnyObject {
    
    func didChange(_ controller: QInAppSubscriptionController, canActive: Bool)
    
}

public class QInAppSubscriptionController {
    
    public let purchases: [QInAppPurchase]
    public private(set) var canActive: Bool
    
    private var _observer: QObserver< IQInAppSubscriptionControllerObserver >

    public init(
        purchases: [QInAppPurchase],
        canActive: Bool
    ) {
        self.purchases = purchases
        self.canActive = canActive
        self._observer = QObserver()
        self._subscribe()
    }
    
    deinit {
        self._unsubscribe()
    }
    
    public func add(observer: IQInAppSubscriptionControllerObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQInAppSubscriptionControllerObserver) {
        self._observer.remove(observer)
    }
    
}

private extension QInAppSubscriptionController {
    
    func _subscribe() {
        for purchase in self.purchases {
            purchase.add(observer: self, priority: .utility)
        }
    }
    
    func _unsubscribe() {
        for purchase in self.purchases {
            purchase.remove(observer: self)
        }
    }
    
    func _canActive() -> Bool? {
        let now = Date()
        for purchase in self.purchases {
            switch purchase.status {
            case .unknown:
                return nil
            case .subcription(let data):
                if now < data.expirationDate {
                    return true
                }
            case .piece, .empty:
                break
            }
        }
        return false
    }
    
}

extension QInAppSubscriptionController : IQInAppPurchaseObserver {
    
    public func didUpdate(_ purchase: QInAppPurchase) {
        if let canActive = self._canActive() {
            if self.canActive != canActive {
                self.canActive = canActive
                self._observer.notify({ $0.didChange(self, canActive: canActive) })
            }
        }
    }
    
}
