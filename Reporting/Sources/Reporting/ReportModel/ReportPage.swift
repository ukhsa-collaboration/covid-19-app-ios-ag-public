//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct ReportPage {
    var name: String
    var sections: [ReportSection]
}

extension ReportPage {

    func save(in reportFolder: URL) throws {
        try? FileManager().createDirectory(at: reportFolder, withIntermediateDirectories: true)

        let reportFile = reportFolder.appendingPathComponent("\(name).json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(JSON.Page(self)).write(to: reportFile)
    }

}

private enum JSON {

    struct Page: Codable {
        var title: String
        var sections: [Section]

        init(_ page: ReportPage) {
            title = page.name
            sections = page.sections.map(Section.init)
        }

    }

    struct Section: Codable {
        var title: String
        var body: String
        var attributes: [Attribute]?
        var checks: [Check]?

        init(_ section: ReportSection) {
            title = section.title
            body = section.body
            attributes = section.attributes?.map(Attribute.init)
            checks = section.checks?.map(Check.init)
        }
    }

    struct Attribute: Codable {
        var attribute: String
        var value: String?

        init(_ attribute: AppAttribute) {
            self.attribute = attribute.name
            value = attribute.value
        }
    }

    struct Check: Codable {
        var check: String
        var passed: Bool
        var notes: String?

        init(_ check: IntegrityCheck) {
            self.check = check.name
            switch check.result {
            case .passed:
                passed = true
                notes = nil
            case .failed(let message):
                passed = false
                notes = message
            }
        }
    }

}
