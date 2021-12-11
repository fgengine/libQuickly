//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit

public class QInAppProduct {
    
    public unowned let purchase: QInAppPurchase
    public private(set) var status: Status
    
    public init(purchase: QInAppPurchase) {
        self.purchase = purchase
        self.status = .unknown
    }
    
    @discardableResult
    public func buy(
        options: QInAppPayment.Options
    ) -> QInAppPayment {
        return self.purchase.buy(
            product: self,
            options: options
        )
    }
    
}

public extension QInAppProduct {
    
    enum Status {
        case unknown
        case loading
        case success(_ info: SKProduct)
        case failure(_ error: Error)
        case missing
    }
    
}

public extension QInAppProduct {
    
    var skProduct: SKProduct? {
        switch self.status {
        case .success(let skProduct): return skProduct
        default: return nil
        }
    }
    
    var localizedPrice: String? {
        guard let skProduct = self.skProduct else { return nil }
        return self.localizedPrice(skProduct: skProduct)
    }
    
    var localizedTitle: String? {
        return self.skProduct?.localizedTitle
    }
    
    var localizedDescription: String? {
        return self.skProduct?.localizedDescription
    }

}

extension QInAppProduct {
    
    func set(status: Status) {
        self.status = status
        self.purchase.didUpdate()
    }
    
    func localizedPrice(skProduct: SKProduct, locale: Locale? = nil) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale ?? skProduct.priceLocale
        return formatter.string(from: skProduct.price)
    }
    
}
