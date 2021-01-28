//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQPageDataSource : IQDataSource where Result : RangeReplaceableCollection {
    
    associatedtype Result
    
    var result: Result? { get }
    var isLoading: Bool { get }
    var isLoadedFirstPage: Bool { get }
    var canMore: Bool { get }

    func load(reload: Bool)
    
}

public extension IQPageDataSource {
    
    var isLoadedFirstPage: Bool {
        return self.result != nil
    }
    
}
