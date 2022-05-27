//
// Copyright © 2020 NHSX. All rights reserved.
//

import SwiftUI

public struct InterfaceSymptomsQuestionnaire {
    public var riskThreshold: Double
    public var symptoms: [SymptomInfo]
    public var cardinal: CardinalSymptomInfo
    public var noncardinal: CardinalSymptomInfo
    public var dateSelectionWindow: Int
    
    public init(riskThreshold: Double, symptoms: [SymptomInfo], cardinal: CardinalSymptomInfo, noncardinal: CardinalSymptomInfo, dateSelectionWindow: Int) {
        self.riskThreshold = riskThreshold
        self.symptoms = symptoms
        self.cardinal = cardinal
        self.noncardinal = noncardinal
        self.dateSelectionWindow = dateSelectionWindow
    }
}

public class SymptomInfo: ObservableObject, Identifiable {
    @Published public var isConfirmed: Bool
    public var heading: String
    public var content: String
    
    public init(isConfirmed: Bool, heading: String, content: String) {
        self.isConfirmed = isConfirmed
        self.heading = heading
        self.content = content
    }
    
    public convenience init() {
        self.init(isConfirmed: false, heading: "-", content: "-")
    }
}

public class CardinalSymptomInfo: ObservableObject, Identifiable {
    @Published public var hasSymptoms: Bool?
    public var heading: String
    public var content: [String]
    
    public init(hasSymptoms: Bool? = nil, heading: String = "", content: [String] = []) {
        self.hasSymptoms = hasSymptoms
        self.heading = heading
        self.content = content
    }
}
