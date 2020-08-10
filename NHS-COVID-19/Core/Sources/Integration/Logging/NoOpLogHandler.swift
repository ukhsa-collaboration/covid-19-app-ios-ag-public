//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Logging

public struct NoOpLogHandler: LogHandler {
    
    public init() {}
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        // Nothing
    }
    
    public var metadata: Logger.Metadata = [:]
    
    public var logLevel: Logger.Level = .critical
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set {
            metadata[key] = newValue
        }
    }
    
}
