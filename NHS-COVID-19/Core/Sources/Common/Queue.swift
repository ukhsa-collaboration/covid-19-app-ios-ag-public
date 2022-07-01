//
// Copyright © 2021 NHSX. All rights reserved.
//

import Foundation

public extension DispatchQueue {

    static func onMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
}
