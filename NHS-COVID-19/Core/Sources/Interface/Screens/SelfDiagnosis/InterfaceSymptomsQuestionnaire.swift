//
// Copyright © 2020 NHSX. All rights reserved.
//

import SwiftUI

public struct InterfaceSymptomsQuestionnaire {
    public var riskThreshold: Double
    public var symptoms: [SymptomInfo]
    public var dateSelectionWindow: Int
    
    public init(riskThreshold: Double, symptoms: [SymptomInfo], dateSelectionWindow: Int) {
        self.riskThreshold = riskThreshold
        self.symptoms = symptoms
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
}
