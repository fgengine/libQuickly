//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSyncDataSource : IQDataSource {
    
    associatedtype Result
    
    var result: Result? { get }
    var isSyncing: Bool { get }
    var isNeedSync: Bool { get }
    
    func setNeedSync()
    func syncIfNeeded()
    
}

public extension IQSyncDataSource {
    
}
