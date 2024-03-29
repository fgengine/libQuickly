//
//  libQuicklyShell
//

import Foundation
import Dispatch
import libQuicklyCore

#if os(macOS)

public class QShell {
    
    public typealias OnData = (_ data: Data) -> Void
    public typealias OnCompletion = (_ result: Result) -> Void
    
    public var isRunning: Bool {
        return self._process.isRunning
    }
    public var result: Result? {
        guard self._process.isRunning == false else { return nil }
        return Self._result(self._process.terminationStatus)
    }
    public let onOutput: OnData?
    public let onError: OnData?
    public let onCompletion: OnCompletion?
    
    private let _queue: DispatchQueue
    private let _process: Process
    private let _outputPipe: Pipe
    private let _errorPipe: Pipe
    
    public init(
        environment: [String : String]? = nil,
        with command: String,
        onOutput: OnData? = nil,
        onError: OnData? = nil,
        onCompletion: OnCompletion? = nil
    ) {
        self.onOutput = onOutput
        self.onError = onError
        self.onCompletion = onCompletion
        
        self._queue = DispatchQueue(label: "QShellQueue")
        
        self._process = Process()
        self._process.launchPath = "/bin/bash"
        self._process.arguments = [ "-c", command ]
        self._process.environment = environment
        
        self._outputPipe = Pipe()
        self._errorPipe = Pipe()
        
        self._process.standardOutput = self._outputPipe
        self._process.standardError = self._errorPipe
        
        self._outputPipe.fileHandleForReading.readabilityHandler = { [unowned self] handler in
            let data = handler.availableData
            self._queue.async(execute: { [unowned self] in
                self.onOutput?(data)
            })
        }
        self._errorPipe.fileHandleForReading.readabilityHandler = { [unowned self] handler in
            let data = handler.availableData
            self._queue.async(execute: { [unowned self] in
                self.onError?(data)
            })
        }
        self._process.terminationHandler = { [unowned self] process in
            self.onCompletion?(Self._result(process.terminationStatus))
        }
        
        self._process.launch()
    }
    
    deinit {
        self._erase()
    }
    
    public func wait() -> Result {
        self._process.waitUntilExit()
        self._erase()
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
    
    enum Result : Equatable {
        case success
        case failure(code: Int32)
    }
    
    struct Run {
        
        public let result: QShell.Result
        public let output: Data
        public let error: Data
        
    }
    
}

public extension QShell {
    
    static func run(
        environment: [String : String]? = nil,
        with command: String,
        at path: String? = nil,
        onOutput: @escaping OnData,
        onError: @escaping OnData
    ) -> QShell.Result {
        let final: String
        if let path = path {
            final = "cd \(path.replacingOccurrences(of: " ", with: "\\ ")) && \(command)"
        } else {
            final = command
        }
        let shell = QShell(
            environment: environment,
            with: final,
            onOutput: onOutput,
            onError: onError
        )
        return shell.wait()
    }
    
    static func run(
        environment: [String : String]? = nil,
        with command: String,
        at path: String? = nil
    ) -> QShell.Run {
        var output = Data()
        var error = Data()
        let result = Self.run(
            environment: environment,
            with: command,
            at: path,
            onOutput: { data in
                output.append(data)
            },
            onError: { data in
                error.append(data)
            }
        )
        return Run(
            result: result,
            output: output,
            error: error
        )
    }
    
}

public extension QShell.Run {
    
    var isSuccess: Bool {
        return self.result == .success
    }
    
}

private extension QShell {
    
    static func _result(_ code: Int32) -> Result {
        switch code {
        case 0: return .success
        default: return .failure(code: code)
        }
    }
    
    func _erase() {
        self._outputPipe.fileHandleForReading.readabilityHandler = nil
        self._errorPipe.fileHandleForReading.readabilityHandler = nil
    }
    
}

#endif
