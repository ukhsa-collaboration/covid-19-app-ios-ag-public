//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public class BackgroundTaskIdentifiers {
    private static let key = "BGTaskSchedulerPermittedIdentifiers"

    let bundle: Bundle

    public init(in bundle: Bundle) {
        self.bundle = bundle
    }

    public var all: [String] {
        bundle.object(forInfoDictionaryKey: Self.key) as? [String] ?? []
    }

    public var exposureNotification: String? {
        all.first { $0.hasSuffix("exposure-notification") }
    }
}
