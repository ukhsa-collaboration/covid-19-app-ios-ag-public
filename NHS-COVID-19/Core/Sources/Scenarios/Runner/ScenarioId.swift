//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import ObjectiveC
import SwiftUI

struct ScenarioId: CaseIterable, Hashable, Identifiable, RawRepresentable {
    
    var scenarioType: AppControllingScenario.Type
    
    init(withType type: AppControllingScenario.Type) {
        scenarioType = type
    }
    
    init?(rawValue: String) {
        guard
            let type = NSClassFromString(rawValue),
            let conformingType = type as? AppControllingScenario.Type else {
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
        // AnyClass.init seems to register new objective-C class the first time it is called.
        //
        // In order for the count variable to reserve enough capacity, we call this method once
        // so that any new classes are registered to the runtime.
        _ = [AnyClass](unsafeUninitializedCapacity: Int(1)) { buffer, initialisedCount in
            initialisedCount = 0
        }
        
        // Improved thanks to some hints from https://stackoverflow.com/a/54150007
        let count = objc_getClassList(nil, 0)
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
            .compactMap { $0 as? AppControllingScenario.Type }
            .map { ScenarioId(withType: $0) }
            .sorted { $0.scenarioType.name < $1.scenarioType.name }
    }()
    
}
