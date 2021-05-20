//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQCursorDataSource : IQPageDataSource {
    
    associatedtype Cursor
    
    var cursor: Cursor? { get }
    
}
