//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenModalable : AnyObject {
    
    var modalPresentation: QScreenModalPresentation { get }
    
}

public enum QScreenModalPresentation {
    
    case simple
    case sheet(info: Sheet)
    
}

public extension QScreenModalPresentation {
    
    struct Sheet {
        
        public let inset: QInset
        public let backgroundView: IQView & IQViewAlphable
        
        public init(
            inset: QInset,
            backgroundView: IQView & IQViewAlphable
        ) {
            self.inset = inset
            self.backgroundView = backgroundView
        }
        
    }
    
}

public extension IQScreenModalable {
    
    var modalPresentation: QScreenModalPresentation {
        return .simple
    }
    
}

public extension IQScreenModalable where Self : IQScreen {
    
    @inlinable
    var modalContentContainer: IQModalContentContainer? {
        guard let contentContainer = self.container as? IQModalContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var modalContainer: IQModalContainer? {
        return self.modalContentContainer?.modalContainer
    }
    
    @inlinable
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.modalContentContainer?.dismiss(animated: animated, completion: completion)
    }
    
}
