//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQPageDataSource : IQDataSource {
    
    var isLoadedFirstPage: Bool { get }
    var isLoading: Bool { get }
    var canLoadMore: Bool { get }

    func load(reload: Bool)
    
}

public extension IQPageDataSource {
    
    var isLoadedFirstPage: Bool {
        return self.result != nil
    }
    
}
