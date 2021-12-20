//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import TPInAppReceipt
import libQuicklyCore
import libQuicklyObserver

public protocol IQInAppRestoreControllerObserver : AnyObject {
    
    func didFinish(_ controller: QInAppRestoreController, purchases: [QInAppPurchase], error: Error?)
    
}

public class QInAppRestoreController {
    
    public let applicationUsername: String?
    public private(set) var isRestoring: Bool
    
    private var _observer: QObserver< IQInAppRestoreControllerObserver >
    private var _purchases: [QInAppPurchase]

    public init(
        applicationUsername: String? = nil
    ) {
        self.applicationUsername = applicationUsername
        self.isRestoring = false
        self._observer = QObserver()
        self._purchases = []
    }
    
    public func add(observer: IQInAppRestoreControllerObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQInAppRestoreControllerObserver) {
        self._observer.remove(observer)
    }
    
    public func restore() {
        guard self.isRestoring == false else { return }
        self.isRestoring = true
        QInAppManager.shared.register(self)
        QInAppManager.shared.restore(
            applicationUsername: self.applicationUsername
        )
    }
    
}

extension QInAppRestoreController {
    
    func restore(purchase: QInAppPurchase) {
        if self._purchases.contains(where: { $0.id == purchase.id }) == false {
            self._purchases.append(purchase)
        }
    }
    
    func finish(error: Error?) {
        self._observer.notify({ $0.didFinish(self, purchases: self._purchases, error: error) })
        self._purchases.removeAll()
        QInAppManager.shared.unregister(self)
        self.isRestoring = false
    }
    
}
