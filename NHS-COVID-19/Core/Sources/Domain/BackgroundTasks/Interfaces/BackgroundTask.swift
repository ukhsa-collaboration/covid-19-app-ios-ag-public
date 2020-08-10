//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks

public protocol BackgroundTask {
    var identifier: String { get }
    var expirationHandler: (() -> Void)? { get nonmutating set }
    func setTaskCompleted(success: Bool)
}

extension BGTask: BackgroundTask {}
