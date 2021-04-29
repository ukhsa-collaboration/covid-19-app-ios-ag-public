//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct KeySharingInfo: Equatable {
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken
    var testResultAcknowledgmentTime: UTCHour
    var hasFinishedInitialKeySharingFlow: Bool
    var hasTriggeredReminderNotification: Bool
}
