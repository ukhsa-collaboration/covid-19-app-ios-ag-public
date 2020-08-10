//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public extension Thread {
    
    /// How a thread exitted.
    enum ExitManner {
        case normal
        case assertion
        case fatalError
    }
    
    /// A thread specific variant of `precondition()`.
    ///
    /// - SeeAlso: `Thread.fatalError`.
    static func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        if !condition() {
            trap(message(), file: file, line: line)
        }
    }
    
    /// A thread specific variant of `assert()`.
    ///
    /// - SeeAlso: `Thread.fatalError`.
    static func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        if !condition() {
            debuggingTrap(message(), file: file, line: line)
        }
    }
    
    /// A thread specific variant of `preconditionFailure()`.
    ///
    /// - SeeAlso: `Thread.fatalError`.
    static func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message(), file: file, line: line)
    }
    
    /// A thread specific variant of `fatalError`.
    ///
    /// If this method was called as part of the `work` passed to `detachSyncSupervised()`, this exits the thread.
    /// Otherwise, the behaviour is the same as calling `Swift.fatalError()`.
    static func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message(), file: file, line: line)
    }
    
    /// Performs `work` one a new thread and waits for it to complete.
    ///
    /// Calls to `Thread.fatalError()` inside `work` will not terminate the app and instead only exit the thread.
    /// This can be useful, for example, when testing that a method traps on invalid input.
    ///
    /// - Parameter work: The work to perform
    /// - Returns: `fatalError` if `work` terminated due to a trap (e.g. `Thread.fatalError` was called); `normal` otherwise.
    static func detachSyncSupervised(_ work: @escaping () -> Void) -> ExitManner {
        var reason = ExitManner.normal
        let sema = DispatchSemaphore(value: 0)
        let thread = Thread {
            Thread.current.trapHandler = { debugging in
                reason = debugging ? .assertion : .fatalError
                sema.signal()
                Thread.exit()
                fatalError("Unreachable")
            }
            work()
            sema.signal()
        }
        thread.start()
        sema.wait()
        return reason
    }
    
}

private extension Thread {
    
    typealias TrapHandler = (_ debugging: Bool) -> Never
    
    private struct Box {
        var trapHandler: TrapHandler?
    }
    
    private static let trapHandlerKey = UUID().uuidString
    
    var trapHandler: TrapHandler? {
        get {
            Thread.current.threadDictionary[type(of: self).trapHandlerKey] as? TrapHandler
        }
        set {
            Thread.current.threadDictionary[type(of: self).trapHandlerKey] = newValue
        }
    }
    
    static func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
        if let trapHandler = Thread.current.trapHandler {
            trapHandler(false)
        } else {
            Swift.fatalError(message(), file: file, line: line)
        }
    }
    
    static func debuggingTrap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) {
        if let trapHandler = Thread.current.trapHandler {
            trapHandler(true)
        } else {
            Swift.assertionFailure(message(), file: file, line: line)
        }
    }
    
}
