//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks

public protocol BackgroundJob {
    var identifier: String { get }
    var expirationHandler: (() -> Void)? { get nonmutating set }
    func setTaskCompleted(success: Bool)
}

extension BGTask: BackgroundJob {}
