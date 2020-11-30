//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public extension QAnimation {
    
    class DisplayLink : NSObject {
        
        weak var delegate: IQAnimationQueueDelegate?
        
        var isRunning: Bool {
            return self._displayLink != nil
        }
        
        private var _displayLink: CADisplayLink?
        private var _prevTime: CFTimeInterval!
        
        func start() {
            if self._displayLink == nil {
                let displayLink = CADisplayLink(target: self, selector: #selector(self._handle))
                displayLink.add(to: .main, forMode: .default)
                self._displayLink = displayLink
                self._prevTime = CACurrentMediaTime()
            }
        }
        
        func stop() {
            if let displayLink = self._displayLink {
                displayLink.remove(from: .main, forMode: .default)
                displayLink.isPaused = true
                displayLink.invalidate()
            }
            self._displayLink = nil
        }
        
    }
    
}

private extension QAnimation.DisplayLink {
    
    @objc
    func _handle() {
        let now = CACurrentMediaTime()
        let delta = now - self._prevTime
        self._prevTime = now
        self.delegate?.update(QFloat(delta))
    }
    
}

#endif
