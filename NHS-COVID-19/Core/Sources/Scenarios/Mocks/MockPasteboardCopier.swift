//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

public class MockPasteboardCopier: PasteboardCopying {
    
    public var copiedString: String?
    
    public init() {}
    
    public func copyToPasteboard(value: String) {
        copiedString = value
    }
    
}
