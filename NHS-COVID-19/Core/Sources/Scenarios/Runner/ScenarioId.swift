//
// Copyright © 2021 DHSC. All rights reserved.
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
        // Improved thanks to some hints from https://stackoverflow.com/a/54150007
        
        // Add 1 since `objc_getClassList` seems to return a count increased by 1
        // the second time we call it.
        let count = objc_getClassList(nil, 0) + 1
        let classes = [AnyClass](unsafeUninitializedCapacity: Int(count)) { buffer, initialisedCount in
            let autoreleasingPointer = AutoreleasingUnsafeMutablePointer<AnyClass>(buffer.baseAddress)
            initialisedCount = Int(objc_getClassList(autoreleasingPointer, count))
        }
        
        return classes
            .lazy
            // The `filter` is necessary; otherwise we may crash.
            //
            // The cast using `as?` calls some objective-c methods on the type to check for conformance. But certain
            // system types do not implement that method and would cause a crash (possible bug in the runtime?).
            //
            // `class_conformsToProtocol` is safe to call on all types, so we use to filter down to “our” classes before
            // we try to cast them.
            .filter { class_conformsToProtocol($0, IdentifiableType.self) }
            .compactMap { $0 as? Scenario.Type }
            .map { ScenarioId(withType: $0) }
            .sorted { $0.scenarioType.name < $1.scenarioType.name }
    }()
    
}
