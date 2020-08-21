//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public protocol PasteboardCopying {
    func copyToPasteboard(value: String)
}

public class PasteboardCopier: PasteboardCopying {
    public init() {}
    
    public func copyToPasteboard(value: String) {
        UIPasteboard.general.string = value
    }
    
}
