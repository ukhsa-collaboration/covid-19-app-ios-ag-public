//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation
import Logging

public extension Publisher {
    func log(into logger: Logger, level: Logger.Level = .debug, _ message: @escaping @autoclosure () -> Logger.Message, file: String = #file, function: String = #function, line: UInt = #line) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { value in
            logger.log(level: level, message(), metadata: .describing(value), source: nil, file: file, function: function, line: line)
        })
    }
}
