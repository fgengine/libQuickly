//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit

public struct QInAppStore {
}

public extension QInAppStore {
    
    static var isAvailable: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    @available(iOS 13.4, *)
    func showPriceConsentIfNeeded() {
        QInAppManager.shared.showPriceConsentIfNeeded()
    }
    
    @available(iOS 14.0, *)
    func presentCodeRedemptionSheet() {
        QInAppManager.shared.presentCodeRedemptionSheet()
    }
    
}
