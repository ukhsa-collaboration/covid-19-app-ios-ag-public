//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation
import XCTest

private enum AwaitError: Error {
    case timedOut
}

extension Publisher {
    
    /// Waits as long as the timeout for the publisher to emit a single value and returns it; otherwise throws an error
    /// - Parameter timeout: The duration to wait for an event.
    public func await(timeout: TimeInterval = 0.1) throws -> Result<Output, Failure> {
        var capturedResult: Result<Output, Failure>?
        
        let complete = { (result: Result<Output, Failure>) in
            capturedResult = result
        }
        
        let cancellable =
            sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        complete(.failure(error))
                    }
                },
                receiveValue: {
                    complete(.success($0))
                }
            )
        defer {
            cancellable.cancel()
        }
        
        let deadline = Date(timeIntervalSinceNow: timeout)
        while
            deadline > Date(),
            capturedResult == nil,
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1)) {
            if let capturedResult = capturedResult {
                return capturedResult
            }
        }
        if let capturedResult = capturedResult {
            return capturedResult
        } else {
            throw AwaitError.timedOut
        }
    }
    
}
