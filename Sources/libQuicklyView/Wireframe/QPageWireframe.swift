//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QPageWireframe< Screen : IQScreen > : IQWireframe {
    
    public private(set) var container: QPageContainer< Screen >
    
    public init(screen: Screen) {
        self.container = QPageContainer(screen: screen)
    }

}
