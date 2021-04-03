//
//  libQuicklyView
//

#if os(OSX)

import AppKit
import libQuicklyCore

public extension QAnimation {
    
    class DisplayLink {
        
        unowned var delegate: IQAnimationQueueDelegate?
        
        var isRunning: Bool {
            return CVDisplayLinkIsRunning(self._displayLink)
        }
        
        fileprivate var _displayLink: CVDisplayLink!
        fileprivate var _prevTime: CVTimeStamp!
        
        init?() {
            guard CVDisplayLinkCreateWithActiveCGDisplays(&self._displayLink) == kCVReturnSuccess else {
                return nil
            }
            guard CVDisplayLinkSetOutputCallback(self._displayLink!, QAnimationDisplayLinkCallback, Unmanaged.passUnretained(self).toOpaque()) == kCVReturnSuccess else {
                return nil
            }
            guard CVDisplayLinkSetCurrentCGDisplay(self._displayLink!, CGMainDisplayID()) == kCVReturnSuccess else {
                return nil
            }
            guard CVDisplayLinkGetCurrentTime(self._displayLink!, &self._prevTime) == kCVReturnSuccess else {
                return nil
            }
        }
        
        deinit {
            self.stop()
        }
        
        func start() {
            CVDisplayLinkStart(self._displayLink)
        }
        
        func stop() {
            CVDisplayLinkStop(self._displayLink)
        }
        
    }
    
}

fileprivate func QAnimationDisplayLinkCallback(_ displayLink: CVDisplayLink, _ nowTime: UnsafePointer< CVTimeStamp >, _ outputTime: UnsafePointer< CVTimeStamp >, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer< CVOptionFlags >, _ context: UnsafeMutableRawPointer?) -> CVReturn {
    guard let context = context else { return kCVReturnSuccess }
    let displayLink = Unmanaged< QAnimation.DisplayLink >.fromOpaque(context).takeRetainedValue()
    let delta = QFloat(outputTime.pointee.videoTime - displayLink._prevTime.videoTime) / QFloat(outputTime.pointee.videoTimeScale)
    displayLink._prevTime = outputTime.pointee
    displayLink.delegate?.update(delta)
    return kCVReturnSuccess
}

#endif
