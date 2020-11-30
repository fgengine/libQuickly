//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenContainer : IQContainer, IQContainerParentable, IQContainerScreenable where Screen : IQScreenViewable {
}
