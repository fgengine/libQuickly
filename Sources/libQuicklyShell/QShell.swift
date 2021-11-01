//
//  libQuicklyShell
//

import Foundation
import Dispatch
import libQuicklyCore

public class QShell {
    
    public typealias OnCompletion = (_ result: Result) -> Void
    
    public var isRunning: Bool {
        return self._process.isRunning
    }
    public var result: Result? {
        guard self._process.isRunning == false else { return nil }
        return Self._result(self._process.terminationStatus)
    }
    public let outputBuffer: IQShellBuffer
    public let errorBuffer: IQShellBuffer
    public let onCompletion: OnCompletion
    
    private let _queue: DispatchQueue
    private let _process: Process
    private let _outputPipe: Pipe
    private let _errorPipe: Pipe
    
    public init(
        with command: String,
        outputBuffer: IQShellBuffer,
        errorBuffer: IQShellBuffer,
        onCompletion: @escaping OnCompletion
    ) {
        self.outputBuffer = outputBuffer
        self.errorBuffer = errorBuffer
        self.onCompletion = onCompletion
        
        self._queue = DispatchQueue(label: "QShellQueue")
        
        self._process = Process()
        self._process.launchPath = "/bin/bash"
        self._process.arguments = [ "-c", command ]
        
        self._outputPipe = Pipe()
        self._errorPipe = Pipe()
        
        self._process.standardOutput = self._outputPipe
        self._process.standardError = self._errorPipe
        
        self._outputPipe.fileHandleForReading.readabilityHandler = { [unowned self] handler in
            let data = handler.availableData
            self._queue.async(execute: { [unowned self] in
                self.outputBuffer.append(data: data)
            })
        }
        self._errorPipe.fileHandleForReading.readabilityHandler = { [unowned self] handler in
            let data = handler.availableData
            self._queue.async(execute: { [unowned self] in
                self.errorBuffer.append(data: data)
            })
        }
        self._process.terminationHandler = { [unowned self] process in
            self.onCompletion(Self._result(process.terminationStatus))
        }
        
        self._process.launch()
    }
    
    deinit {
        self._outputPipe.fileHandleForReading.readabilityHandler = nil
        self._errorPipe.fileHandleForReading.readabilityHandler = nil
    }
    
    public func wait() -> Result {
        self._process.waitUntilExit()
        return self._queue.sync(execute: {
            return Self._result(self._process.terminationStatus)
        })
    }
    
}

extension QShell : IQCancellable {
    
    public func cancel() {
        self._process.terminate()
    }
    
}

public extension QShell {
    
    enum Result {
        case success
        case failure(code: Int32)
    }
    
}

private extension QShell {
    
    static func _result(_ code: Int32) -> Result {
        switch code {
        case 0: return .success
        default: return .failure(code: code)
        }
    }
    
}
