//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct ArtefactReporter {

    func report(for appURL: URL) throws -> Report {

        let application = try Application(url: appURL)
        let appInfo = application.appInfo

        let appInfoReporter = AppInfoReporter(compilationRequirements: App.compilationRequirements)
        let appFilesReporter = AppFilesReporter()

        return Report(
            pages: [
                ReportPage(
                    name: "Overview",
                    sections: [
                        [
                            ReportSection(
                                title: "App Icon",
                                content: "![App icon](Attachments/Icon.png)"
                            ),
                        ],
                        appInfoReporter.overviewSections(for: appInfo),
                        [
                            ReportSection(
                                title: "Integrity Checks",
                                content: "See [Integrity Checks](Integrity Checks.md) for more technical reports."
                            ),
                        ],
                    ].flatMap { $0 }
                ),
                ReportPage(
                    name: "Integrity Checks",
                    sections: [
                        appInfoReporter.technicalSections(for: appInfo),
                        appFilesReporter.reportSections(forAppAt: appURL, info: appInfo),
                    ].flatMap { $0 }
                ),
            ],
            attachments: appFilesReporter.attachments(forAppAt: appURL, info: appInfo)
        )
    }
}
