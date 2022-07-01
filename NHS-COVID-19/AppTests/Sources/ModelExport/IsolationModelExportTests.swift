//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import Foundation
import UniformTypeIdentifiers
import XCTest

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
            source: .init(
                commit: try findCommit(),
                referenceBasePath: IsolationModel.Reference.basePath
            ),
            transitions: IsolationModelCurrentRuleSet.validTransitions
        )

        let path = exportFolder.appendingPathComponent("Transitions", conformingTo: .json)

        try? FileManager().createDirectory(at: exportFolder, withIntermediateDirectories: true, attributes: nil)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(export).write(to: path)
    }

    private func findCommit() throws -> String {
        // This is fairly hacky.
        // Wanted to find a method that (at least for now) we don't need to change the build process or scripts.
        //
        // Since this is only used in tests and internally, we should be able to fix it quickly if it breaks.
        let settingsPlist = Bundle.main.bundleURL.appendingPathComponent("Settings.bundle/Root.plist")
        let settings = try PropertyListDecoder().decode(Settings.self, from: Data(contentsOf: settingsPlist))
        let build = settings.PreferenceSpecifiers.first { $0.Key == "app_build_constant" }?.DefaultValue

        return build?.split(whereSeparator: "(-)".contains).dropFirst().first.map(String.init) ?? ""
    }
}

private struct Export: Codable {
    struct Source: Codable {
        var commit: String
        var referenceBasePath: String
    }

    var source: Source
    var transitions: [IsolationModel.Transition]
}

private struct Settings: Codable {
    struct Specifier: Codable {
        var Key: String
        var DefaultValue: String
    }

    var PreferenceSpecifiers: [Specifier]
}
