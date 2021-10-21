//
//  libQuicklyLog
//

import Foundation

public class QLog {
    
    private var _targets: [IQLogTarget]
    
    public init(
        targets: [IQLogTarget]
    ) {
        self._targets = targets
    }
    
}

public extension QLog {
    
    static var shared = QLog(
        targets: [
            Target.Default()
        ]
    )
    
}

public extension QLog {
    
    func append(target: IQLogTarget) {
        guard self._targets.contains(where: {$0 === target }) == false else { return }
        self._targets.append(target)
    }
    
    func remove(target: IQLogTarget) {
        guard let index = self._targets.firstIndex(where: { $0 === target }) else { return }
        self._targets.remove(at: index)
    }
    
}

public extension QLog {
    
    func log(level: QLog.Level, category: String, message: String) {
        for target in self._targets {
            target.log(level: level, category: category, message: message)
        }
    }
    
    @inlinable
    func log< Sender : AnyObject >(level: QLog.Level, module object: Sender, message: String) {
        self.log(level: level, category: String(describing: object), message: message)
    }
    
    @inlinable
    func log< Sender : AnyObject >(level: QLog.Level, class object: Sender, message: String) {
        self.log(level: level, category: String(describing: type(of: object)), message: message)
    }
    
}
