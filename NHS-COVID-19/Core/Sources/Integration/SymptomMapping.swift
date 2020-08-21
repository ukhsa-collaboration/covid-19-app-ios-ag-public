//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface

public class SymptomMapping {
    
    private var domainSymptoms = [SymptomInfo.ID: Symptom]()
    
    func interfaceSymptomFrom(domainSymptom: Symptom) -> SymptomInfo {
        let language = Bundle.preferredLocalizations(from: Array(domainSymptom.title.keys)).first ?? "en-GB"
        let heading = domainSymptom.title[language]!
        let content = domainSymptom.description[language]!
        
        let viewModel = SymptomInfo(isConfirmed: false, heading: heading, content: content)
        domainSymptoms[viewModel.id] = domainSymptom
        return viewModel
    }
    
    func domainSymptomFrom(interfaceSymptom: SymptomInfo) -> Symptom {
        guard let symptom = domainSymptoms[interfaceSymptom.id] else {
            preconditionFailure("requested domain symptom for an interfaceSymptom that was not created by us")
        }
        
        return symptom
    }
}
