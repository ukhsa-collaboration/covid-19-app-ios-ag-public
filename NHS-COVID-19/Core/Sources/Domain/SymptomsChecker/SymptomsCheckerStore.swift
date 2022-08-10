//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

private struct SymptomsCheckerInfo: Codable, DataConvertible, Equatable {
    var lastCompletedSymptomsQuestionnaireDay: GregorianDay?
    var toldToStayHome: Bool
}

class SymptomsCheckerStore {

    @PublishedEncrypted private var symptomsCheckerInfo: SymptomsCheckerInfo?

    var configuration: SymptomsCheckerConfiguration { .default }

    private(set) lazy var lastCompletedSymptomsQuestionnaireDay: DomainProperty<GregorianDay?> = {
        $symptomsCheckerInfo.map { $0?.lastCompletedSymptomsQuestionnaireDay }
    }()

    private(set) lazy var toldToStayHome: DomainProperty<Bool?> = {
        $symptomsCheckerInfo.map { $0?.toldToStayHome }
    }()

    init(store: EncryptedStoring) {
        _symptomsCheckerInfo = store.encrypted("symptoms_checker_store")
    }

    func save(lastCompletedSymptomsQuestionnaireDay: GregorianDay, toldToStayHome: Bool) {
        symptomsCheckerInfo = SymptomsCheckerInfo(
            lastCompletedSymptomsQuestionnaireDay: lastCompletedSymptomsQuestionnaireDay,
            toldToStayHome: toldToStayHome
        )

        Metrics.signpost(.completedV2SymptomsQuestionnaire)
        if toldToStayHome {
            Metrics.signpost(.completedV2SymptomsQuestionnaireAndStayAtHome)
        } else
        { Metrics.signpost(.completedV3SymptomsQuestionnaireAndHasSymptoms)

        }
    }

    func delete() {
        symptomsCheckerInfo = nil
    }
}
