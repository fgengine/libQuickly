//
//  libQuicklyView
//

import Foundation


public protocol IQLayoutDelegate : AnyObject {
    
    func bounds(_ layout: IQLayout) -> QRect
    
    func setNeedUpdate(_ layout: IQLayout)
    func updateIfNeeded(_ layout: IQLayout)
    
}

public protocol IQLayout : AnyObject {
    
    var delegate: IQLayoutDelegate? { set get }
    var parentView: IQView? { set get }
    var items: [IQLayoutItem] { get }
    var size: QSize { get }
    var isValid: Bool { get }
    
    func setNeedUpdate()
    func updateIfNeeded()

    func layout()
    
    func size(_ available: QSize) -> QSize
    
}

public extension IQLayout {
    
    var isValid: Bool {
        return self.size.width > 0 || self.size.height > 0
    }
    
    func setNeedUpdate() {
        self.delegate?.setNeedUpdate(self)
    }
    
    func updateIfNeeded() {
        self.delegate?.updateIfNeeded(self)
    }
    
}
