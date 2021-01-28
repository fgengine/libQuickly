//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSimpleParamsActionDataSource : IQActionDataSource {
    
    associatedtype Params

    func perform(_ params: Params)
    
}
