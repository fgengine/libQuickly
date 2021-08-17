//
//  libQuicklyView
//

import Foundation
import libQuicklyCore


public protocol IQStateContainer : IQContainer, IQContainerParentable {
    
    typealias ContentContainer = IQContainer & IQContainerParentable
    
    var container: ContentContainer? { set get }
    
}
