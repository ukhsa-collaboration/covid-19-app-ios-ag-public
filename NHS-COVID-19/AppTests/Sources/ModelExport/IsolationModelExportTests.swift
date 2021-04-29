//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest
import BehaviourModels
import UniformTypeIdentifiers

@available(iOS 14.0, *)
class IsolationModelExportTests: XCTestCase {
    
    let runner = ReportRunner()
    
    func testModelExport() throws {
        guard ProcessInfo().environment["test_mode"] == "textReport" else {
            return
        }
        
        let modelExportFolder = try XCTUnwrap(Bundle(for: Self.self).infoDictionary?["modelExportFolder"] as? String)
        
        let exportFolder = URL(fileURLWithPath: modelExportFolder)
        
        let export = Export(
            transitions: IsolationModelCurrentRuleSet.validTransitions
        )
        
        let path = exportFolder.appendingPathComponent("Transitions", conformingTo: .json)
        
        try? FileManager().createDirectory(at: exportFolder, withIntermediateDirectories: true, attributes: nil)
        try JSONEncoder().encode(export).write(to: path)
    }
}

private struct Export: Codable {
    var transitions: [IsolationModel.Transition]
}
