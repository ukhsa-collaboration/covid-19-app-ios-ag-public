//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

private struct KeySharingPayload: Codable, DataConvertible {
    fileprivate struct Info: Codable, DataConvertible {
        var diagnosisKeySubmissionToken: String
        var testResultAcknowledgmentTime: UTCHour
        var hasFinishedInitialKeySharingFlow: Bool
        var hasTriggeredReminderNotification: Bool
    }
    
    var keySharingInfo: Info?
}

private extension KeySharingInfo {
    init(_ info: KeySharingPayload.Info) {
        self.init(
            diagnosisKeySubmissionToken: .init(value: info.diagnosisKeySubmissionToken),
            testResultAcknowledgmentTime: info.testResultAcknowledgmentTime,
            hasFinishedInitialKeySharingFlow: info.hasFinishedInitialKeySharingFlow,
            hasTriggeredReminderNotification: info.hasTriggeredReminderNotification
        )
    }
}

private extension KeySharingPayload.Info {
    init(_ info: KeySharingInfo) {
        self.init(
            diagnosisKeySubmissionToken: info.diagnosisKeySubmissionToken.value,
            testResultAcknowledgmentTime: info.testResultAcknowledgmentTime,
            hasFinishedInitialKeySharingFlow: info.hasFinishedInitialKeySharingFlow,
            hasTriggeredReminderNotification: info.hasTriggeredReminderNotification
        )
    }
}

class KeySharingStore {
    
    @PublishedEncrypted private var keySharingPayload: KeySharingPayload?
    
    @available(*, deprecated, message: "Use `info` instead.")
    public enum State: Equatable {
        case empty
        case hasNotReminded(token: String, time: UTCHour)
        case hasReminded(token: String, time: UTCHour)
    }
    
    private(set) lazy var info: DomainProperty<KeySharingInfo?> = {
        $keySharingPayload.map { $0?.keySharingInfo.map(KeySharingInfo.init) }
    }()
    
    @available(*, deprecated, message: "Use `info` instead.")
    private(set) lazy var state: DomainProperty<State?> = {
        $keySharingPayload
            .map {
                guard let info = $0?.keySharingInfo else {
                    return .empty
                }
                
                if info.hasFinishedInitialKeySharingFlow {
                    return .hasReminded(token: info.diagnosisKeySubmissionToken, time: info.testResultAcknowledgmentTime)
                } else {
                    return .hasNotReminded(token: info.diagnosisKeySubmissionToken, time: info.testResultAcknowledgmentTime)
                }
            }
    }()
    
    init(store: EncryptedStoring) {
        _keySharingPayload = store.encrypted("key_sharing")
    }
    
    func save(token: DiagnosisKeySubmissionToken,
              acknowledgmentTime: UTCHour) {
        keySharingPayload = KeySharingPayload(
            keySharingInfo: .init(KeySharingInfo(
                diagnosisKeySubmissionToken: token,
                testResultAcknowledgmentTime: acknowledgmentTime,
                hasFinishedInitialKeySharingFlow: false,
                hasTriggeredReminderNotification: false
            ))
        )
    }
    
    func didFinishInitialKeySharingFlow() {
        keySharingPayload = mutating(keySharingPayload) {
            $0?.keySharingInfo?.hasFinishedInitialKeySharingFlow = true
        }
    }
    
    func didTriggerReminderNotification() {
        keySharingPayload = mutating(keySharingPayload) {
            $0?.keySharingInfo?.hasTriggeredReminderNotification = true
        }
    }
    
    func reset() {
        keySharingPayload = nil
    }
}
