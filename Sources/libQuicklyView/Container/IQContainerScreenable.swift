//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public protocol IQContainerScreenable : AnyObject {
    
    associatedtype Screen : IQScreen
    
    var screen: Screen { get }
    
}
