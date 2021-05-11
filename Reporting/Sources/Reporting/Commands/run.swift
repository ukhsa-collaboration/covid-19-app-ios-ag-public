//
// Copyright © 2021 DHSC. All rights reserved.
//

import ArgumentParser

public func run() -> Never {
    ReportCommand.main()
}

struct ReportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "report",
        abstract: "A tool for producing reports from iOS app bundles.",
        subcommands: [
            ArchiveReportCommand.self,
            IPAReportCommand.self,
            WorkspaceReportCommand.self,
            ConfigureCommand.self,
            ExportCommand.self,
            ValidateCommand.self,
            UploadCommand.self,
            VersioningCommand.self,
            DeployLatestCommand.self,
            GetCommand.self,
            GitTagForNewVersion.self,
            TestResultsSummaryCommand.self,
            UnusedLocalizableKeysSummaryCommand.self,
        ]
    )
    
    func run() throws {
        print("running")
    }
}
