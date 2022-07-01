//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import ExposureNotification
import Localization

extension ENManager: ExposureNotificationManaging {

    public func getExposureInfo(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureInfoHandler) {
        getExposureInfo(summary: summary, userExplanation: localize(.user_notification_explanation), completionHandler: completionHandler)
    }

    public var instanceAuthorizationStatus: ENAuthorizationStatus {
        Self.authorizationStatus
    }

    public var exposureNotificationStatusPublisher: AnyPublisher<Status, Never> {
        publisher(for: \.exposureNotificationStatus, options: [.initial, .new])
            .eraseToAnyPublisher()
    }

    public var exposureNotificationEnabledPublisher: AnyPublisher<Bool, Never> {
        publisher(for: \.exposureNotificationEnabled, options: [.initial, .new])
            .eraseToAnyPublisher()
    }
}
