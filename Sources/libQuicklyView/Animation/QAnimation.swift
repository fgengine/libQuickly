//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol IQAnimationQueueDelegate : AnyObject {
    
    func update(_ delta: TimeInterval)
    
}

public class QAnimation {
    
    public static let `default` = QAnimation()
    
    private var _tasks: [Task]
    private var _displayLink: DisplayLink!
    
    private init() {
        self._tasks = []
        self._displayLink = DisplayLink()
        self._displayLink?.delegate = self
    }
    
    deinit {
        self._displayLink.stop()
    }
    
    @discardableResult
    public func run(
        duration: TimeInterval,
        elapsed: TimeInterval = 0,
        ease: IQAnimationEase = Ease.Linear(),
        preparing: (() -> Void)? = nil,
        processing: @escaping (_ progress: Float) -> Void,
        completion: @escaping () -> Void
    ) -> IQAnimationTask {
        let task = Task(
            duration: duration,
            elapsed: elapsed,
            ease: ease,
            preparing: preparing,
            processing: processing,
            completion: completion
        )
        self._tasks.append(task)
        if self._displayLink.isRunning == false {
            self._displayLink.start()
        }
        return task
    }
    
}

public extension QAnimation {
    
    struct Ease {
    }
    
}

private extension QAnimation {
    
    class Task : IQAnimationTask {
        
        var duration: TimeInterval
        var elapsed: TimeInterval
        var ease: IQAnimationEase
        var preparing: (() -> Void)?
        var processing: (_ progress: Float) -> Void
        var completion: () -> Void
        
        var isRunning: Bool
        var isCompletion: Bool
        var isCanceled: Bool
        
        @inlinable
        init(
            duration: TimeInterval,
            elapsed: TimeInterval,
            ease: IQAnimationEase,
            preparing: (() -> Void)?,
            processing: @escaping (_ progress: Float) -> Void,
            completion: @escaping () -> Void
        ) {
            self.duration = duration
            self.elapsed = elapsed
            self.ease = ease
            self.preparing = preparing
            self.processing = processing
            self.completion = completion
            self.isRunning = false
            self.isCompletion = false
            self.isCanceled = false
        }
        
        @inlinable
        func update(_ delta: TimeInterval) {
            if self.isRunning == false {
                self.isRunning = true
                self.preparing?()
            }
            if self.isCanceled == false {
                self.elapsed += delta
                let rawProgress = Float(min(self.elapsed / self.duration, 1))
                let easeProgress = self.ease.perform(rawProgress)
                self.processing(easeProgress)
                if self.elapsed >= self.duration && self.isCompletion == false {
                    self.isCompletion = true
                }
            }
        }
        
        func cancel() {
            guard self.isCompletion == false else { return }
            self.isCanceled = true
        }

    }
    
}

extension QAnimation : IQAnimationQueueDelegate {
    
    func update(_ delta: TimeInterval) {
        var removingTask: [Task] = []
        for task in self._tasks {
            task.update(delta)
            if task.isCompletion == true || task.isCanceled == true {
                removingTask.append(task)
            }
        }
        if removingTask.count > 0 {
            self._tasks.removeAll(where: { task in
                return removingTask.contains(where: { return task === $0 })
            })
            for task in removingTask {
                if task.isCompletion == true {
                    task.completion()
                }
            }
        }
        if self._tasks.count == 0 {
            self._displayLink.stop()
        }
    }
    
}
