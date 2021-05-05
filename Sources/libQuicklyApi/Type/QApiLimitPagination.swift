//
//  libQuicklyApi
//

import Foundation

public struct QApiLimitPagination {
    
    public let offset: UInt
    public let limit: UInt
    
    public init(
        offset: UInt,
        limit: UInt
    ) {
        self.offset = offset
        self.limit = limit
    }
    
    public func next() -> Self {
        return Self(offset: self.offset + self.limit, limit: self.limit)
    }
    
}
