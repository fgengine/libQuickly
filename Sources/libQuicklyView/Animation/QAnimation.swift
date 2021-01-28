//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol IQAnimationQueueDelegate : AnyObject {
    
    func update(_ delta: QFloat)
    
}

public class QAnimation {
    
    public static let `default` = QAnimation()
    
    private var _blocks: [Block]
    private var _displayLink: DisplayLink!
    
    private init() {
        self._blocks = []
        self._displayLink = DisplayLink()
        self._displayLink?.delegate = self
    }
    
    deinit {
        self._displayLink.stop()
    }
    
    public func run(
        duration: QFloat,
        elapsed: QFloat = 0,
        ease: IQAnimationEase = Ease.Linear(),
        processing: @escaping (_ progress: QFloat) -> Void,
        completion: @escaping () -> Void
    ) {
        self._blocks.append(Block(
            duration: duration,
            elapsed: elapsed,
            ease: ease,
            processing: processing,
            completion: completion
        ))
        if self._displayLink.isRunning == false {
            self._displayLink.start()
        }
    }
    
}

public extension QAnimation {
    
    struct Ease {
    }
    
}

private extension QAnimation {
    
    class Block {
        
        var duration: QFloat
        var elapsed: QFloat
        var ease: IQAnimationEase
        var processing: (_ progress: QFloat) -> Void
        var completion: () -> Void
        
        var isRunning: Bool
        var isCompletion: Bool
        
        @inlinable
        init(
            duration: QFloat,
            elapsed: QFloat,
            ease: IQAnimationEase,
            processing: @escaping (_ progress: QFloat) -> Void,
            completion: @escaping () -> Void
        ) {
            self.duration = duration
            self.elapsed = elapsed
            self.ease = ease
            self.processing = processing
            self.completion = completion
            self.isRunning = false
            self.isCompletion = false
        }
        
        @inlinable
        func update(_ delta: QFloat) {
            if self.isRunning == false {
                self.isRunning = true
            }
            self.elapsed += delta
            let rawProgress = min(self.elapsed / self.duration, 1)
            let easeProgress = self.ease.perform(rawProgress)
            self.processing(easeProgress)
            if self.elapsed >= self.duration && self.isCompletion == false {
                self.isCompletion = true
            }
        }

    }
    
}

extension QAnimation : IQAnimationQueueDelegate {
    
    func update(_ delta: QFloat) {
        var removingBlock: [Block] = []
        for block in self._blocks {
            block.update(delta)
            if block.isCompletion == true {
                removingBlock.append(block)
            }
        }
        if removingBlock.count > 0 {
            self._blocks.removeAll(where: { block in
                return removingBlock.contains(where: { return block === $0 })
            })
            for block in removingBlock {
                block.completion()
            }
        }
        if self._blocks.count == 0 {
            self._displayLink.stop()
        }
    }
    
}
