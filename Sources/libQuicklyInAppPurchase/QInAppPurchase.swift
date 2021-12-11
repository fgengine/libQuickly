//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import libQuicklyCore
import libQuicklyObserver

public protocol IQInAppPurchaseObserver : AnyObject {
    
    func didUpdate(_ purchase: QInAppPurchase)
    
}

public class QInAppPurchase {
    
    public let id: String
    public private(set) var status: Status
    public private(set) var product: QInAppProduct?
    public private(set) var payment: QInAppPayment?
    
    private var _observer: QObserver< IQInAppPurchaseObserver >
    
    public init(id: String) {
        self.id = id
        self.status = .unknown
        self._observer = QObserver()
        QInAppManager.shared.register(self)
    }
    
    deinit {
        QInAppManager.shared.unregister(self)
    }
    
    @discardableResult
    public func load() -> QInAppProduct {
        if let product = self.product {
            return product
        }
        let product = QInAppProduct(purchase: self)
        self.product = product
        QInAppManager.shared.load(product: product)
        return product
    }
    
    public func add(observer: IQInAppPurchaseObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQInAppPurchaseObserver) {
        self._observer.remove(observer)
    }
    
}

public extension QInAppPurchase {

    enum Status : Equatable {
        case unknown
        case piece(_ data: [Piece])
        case subcription(_ data: Subcription)
        case empty
    }

}

public extension QInAppPurchase.Status {
    
    struct Piece : Equatable {
        
        public let date: Date
        public var quantity: Int = 1

    }
    
    struct Subcription : Equatable {
        
        public let date: Date
        public let expirationDate: Date
        public let cancelationDate: Date?

    }
    
}

public extension QInAppPurchase {
    
    var skProduct: SKProduct? {
        return self.product?.skProduct
    }
    
}

extension QInAppPurchase {
    
    func buy(
        product: QInAppProduct,
        options: QInAppPayment.Options
    ) -> QInAppPayment {
        if let payment = self.payment {
            switch payment.status {
            case .unknown, .purchasing, .deferred:
                return payment
            case .purchased, .failure, .cancelled:
                break
            }
        }
        let payment = QInAppPayment(purchase: self, options: options)
        self.payment = payment
        QInAppManager.shared.buy(payment: payment)
        return payment
    }
    
    func payment(transaction: SKPaymentTransaction) -> QInAppPayment {
        if let payment = self.payment {
            return payment
        }
        let payment = QInAppPayment(purchase: self, options: QInAppPayment.Options(payment: transaction.payment))
        self.payment = payment
        return payment
    }
    
    func set(status: Status) {
        self.status = status
        self.didUpdate()
    }
    
    func didUpdate() {
        self._observer.notify({ $0.didUpdate(self) })
    }
    
}
