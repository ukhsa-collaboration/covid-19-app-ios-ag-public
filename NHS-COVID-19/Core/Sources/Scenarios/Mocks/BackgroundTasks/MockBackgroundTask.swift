//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation

public class MockBackgroundTask: BackgroundTask {
    public var identifier: String = UUID().uuidString
    public var expirationHandler: (() -> Void)?
    public var taskCompletion: ((Bool) -> Void)?

    public init() {}

    public func setTaskCompleted(success: Bool) {
        taskCompletion?(success)
    }
}
