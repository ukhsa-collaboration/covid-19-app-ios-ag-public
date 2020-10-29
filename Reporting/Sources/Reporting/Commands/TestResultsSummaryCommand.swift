//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct TestResultsSummaryCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "summary",
        abstract: "Produces coverage and testresults (test summary) text files."
    )
    
    @Argument(help: "Path to TestResults json file")
    var testResults: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let testResultURL = URL(fileURLWithPath: testResults, relativeTo: currentDirectory)
        
        let data = try Data(contentsOf: testResultURL, options: .mappedIfSafe)
        
        // Transform TestResults
        
        let testSummaryReportGenerator = TestSummaryReportGenerator()
        let coverageData = try testSummaryReportGenerator.createCoverageSummary(from: data)
        
        // Write coverage data to text file
        
        let coverageTextURL = testResultURL
            .deletingLastPathComponent()
            .appendingPathComponent("coverage")
            .appendingPathExtension("txt")
        
        try coverageData.write(to: coverageTextURL)
    }
}
