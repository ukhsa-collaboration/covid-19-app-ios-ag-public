//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct SymptomsQuestionnaire: Equatable {
    public var symptoms: [Symptom]
    public var riskThreshold: Double
    public var dateSelectionWindow: Int
}

public struct Symptom: Codable, Equatable {
    public typealias LanguageTag = String
    
    public var title: [LanguageTag: String]
    public var description: [LanguageTag: String]
    var riskWeight: Double
}
