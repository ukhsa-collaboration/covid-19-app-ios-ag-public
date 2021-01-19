//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public struct SymptomsQuestionnaire: Equatable {
    public var symptoms: [Symptom]
    public var riskThreshold: Double
    public var dateSelectionWindow: Int
}

public struct Symptom: Decodable, Equatable {
    public var title: LocaleString
    public var description: LocaleString
    var riskWeight: Double
}
