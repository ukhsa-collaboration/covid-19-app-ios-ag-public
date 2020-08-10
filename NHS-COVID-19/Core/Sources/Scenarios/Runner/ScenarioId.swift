//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import ObjectiveC
import SwiftUI

struct ScenarioId: CaseIterable, Hashable, Identifiable, RawRepresentable {
    
    var scenarioType: Scenario.Type
    
    init(withType type: Scenario.Type) {
        scenarioType = type
    }
    
    init?(rawValue: String) {
        guard
            let type = NSClassFromString(rawValue),
            let conformingType = type as? Scenario.Type else {
            return nil
        }
        scenarioType = conformingType
    }
    
    var rawValue: String {
        NSStringFromClass(scenarioType)
    }
    
    var id: ScenarioId { self }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(scenarioType.id)
    }
    
    static func == (lhs: ScenarioId, rhs: ScenarioId) -> Bool {
        lhs.scenarioType.id == rhs.scenarioType.id
    }
    
    static let allCases: [ScenarioId] = {
        var count: UInt32 = 0
        let classes = objc_copyClassList(&count)
        let buffer = UnsafeBufferPointer(start: classes, count: Int(count))
        return Array(
            (0 ..< Int(count))
                .lazy
                .compactMap { buffer[$0] as? Scenario.Type }
                .map { ScenarioId(withType: $0) }
        )
        .sorted { $0.scenarioType.name < $1.scenarioType.name }
    }()
    
}
