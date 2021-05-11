//
// Copyright © 2021 NHSX. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    
    static func onMain(_ work: @escaping () -> ()) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
}
