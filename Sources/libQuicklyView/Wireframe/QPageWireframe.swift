//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QPageWireframe< Screen : IQPageScreen > : IQWireframe {
    
    public private(set) var container: QPageContainer< Screen >
    
    public init(screen: Screen) {
        self.container = QPageContainer(screen: screen)
    }
    
    public func set< Screen: IQScreen & IQScreenViewable & IQScreenPageable >(
        screens: [Screen],
        current: Screen? = nil,
        animated: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let containers = screens.compactMap({ QScreenContainer(screen: $0) })
        self.container.set(
            containers: containers,
            current: current != nil ? containers.first(where: { $0.screen === current }) : nil,
            animated: animated,
            completion: completion
        )
    }
    
    public func set< Screen: IQScreen & IQScreenPageable >(
        current: Screen,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let container = current.container as? IQPageContentContainer else {
            completion?()
            return
        }
        self.container.set(
            current: container,
            animated: animated,
            completion: completion
        )
    }

}
