//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

private enum SummaryReportError: Error {
    case errorDecodingTestResults
    case errorCreatingTestResultsSummary
    case errorCreatingCoverageSummary
}

private struct TestResults: Decodable {
    let targets: [Target]
}

private struct Target: Decodable {
    var coveredLines: Int
    var executableLines: Int
    var lineCoverage: Double
    var name: String
}

struct TestSummaryReportGenerator {
    
    // Targets which we are interested in
    private let targetNames = ["Domain", "Integration", "Localization", "Interface", "Common"]
    
    func createCoverageSummary(from data: Data) throws -> Data {
        let targets: [Target]
        let decoder = JSONDecoder()
        
        // Deserialize
        
        do {
            let jsonData = try decoder.decode(TestResults.self, from: data)
            targets = jsonData.targets.filter { $0.executableLines > 0 && targetNames.contains($0.name) }
            
            if targets.count != targetNames.count {
                throw SummaryReportError.errorDecodingTestResults
            }
        } catch {
            throw SummaryReportError.errorDecodingTestResults
        }
        
        // Transform
        
        let totalCoverage = try calculateTotalCoveragePercentage(from: targets)
        
        let targetPercentages = targets.map {
            "\($0.name): \(($0.lineCoverage * 100).rounded(2))%"
        }.joined(separator: "\n")
        
        // Create Coverage Summary
        
        let result = """
        General:
        ========
        
        Type of coverage used: branch coverage
        
        Coverages of modules:
        =====================
        
        \(targetPercentages)
        
        Total test coverage: \((totalCoverage * 100).rounded(2))%
        """
        
        if let data = result.data(using: .utf8) {
            return data
        } else {
            throw SummaryReportError.errorCreatingCoverageSummary
        }
    }
    
    /// Calculates weighted average percentage
    private func calculateTotalCoveragePercentage(from targets: [Target]) throws -> Double {
        let allLines = targets.map { $0.executableLines }.reduce(0, +)
        let allCovered = targets.map { $0.coveredLines }.reduce(0, +)
        
        guard allCovered < allLines else {
            throw SummaryReportError.errorDecodingTestResults
        }
        
        return Double(allCovered) / Double(allLines)
    }
    
    func createTestResultSummary(from data: Data) throws -> Data {
        
        // Deserialize
        
        let targets = ["AppTests", "DomainTests", "InterfaceTests", "CommonTests", "IntegrationTests"]
        
        let testResults = try JSONDecoder().decode(ActionTestPlanRunSummaries.self, from: data)
        
        guard let targetTests = testResults.summaries.first?.testableSummaries else {
            throw SummaryReportError.errorDecodingTestResults
        }
        
        // Create TestResults Summary
        
        let filtered = targetTests.filter { targets.contains($0.name) }
        let domainTests = filtered.map { DomainTests($0) }
        
        let totalNumberOfTests = domainTests.flatMap { $0.testSuits.flatMap { $0.tests } }.count
        let numberOfPassedTests = domainTests.flatMap { $0.testSuits.flatMap { $0.tests.filter { $0.status == .pass } } }.count
        let numberOfFailedTests = domainTests.flatMap { $0.testSuits.flatMap { $0.tests.filter { $0.status == .fail } } }.count
        
        let result = """
        Summary:
        ========
        
        Total number of tests: \(totalNumberOfTests)
        Number of passed tests: \(numberOfPassedTests)
        Number of failed tests: \(numberOfFailedTests)
        
        Results:
        ========
        
        \(domainTests.customDescription)
        """
        
        if let data = result.data(using: .utf8) {
            return data
        } else {
            throw SummaryReportError.errorCreatingTestResultsSummary
        }
        
    }
}

// MARK: - Helper extensions

extension Double {
    func rounded(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Array where Element: CustomStringConvertible {
    var customDescription: String {
        var description = ""
        for element in self {
            description += element.description + "\n"
        }
        return description
    }
}

// MARK: - Test Result models

private enum TestStatus: String {
    
    case pass = "Success"
    case fail = "Failure"
    case unknown
    
    var getValue: String {
        switch self {
        case .pass: return "Pass"
        case .fail: return "Fail"
        case .unknown: return "Unknown"
        }
    }
}

private struct DomainTests: CustomStringConvertible {
    var name: String
    var testSuits: [TestGroup]
    
    init(_ testableSummary: ActionTestableSummary) {
        name = testableSummary.name
        
        if let testSuitsResult = ((testableSummary.tests.first as? ActionTestSummaryGroup)?.subtests.first as? ActionTestSummaryGroup)?.subtests as? [ActionTestSummaryGroup] {
            // ActionTestSummaryGroup ( holds concrete tests - ActionTestMetadata)
            testSuits = testSuitsResult.map { TestGroup($0) }
        } else {
            testSuits = []
        }
    }
    
    var description: String {
        name + "\n\n" + testSuits.customDescription
    }
}

private struct TestGroup: CustomStringConvertible {
    var name: String
    var tests: [Test]
    
    init(_ actionTestSummaryGroup: ActionTestSummaryGroup) {
        name = actionTestSummaryGroup.name
        if let testsResult = actionTestSummaryGroup.subtests as? [ActionTestMetadata] {
            tests = testsResult.map { Test($0) }
        } else {
            tests = []
        }
    }
    
    var description: String {
        "\(name):\n\(tests.customDescription)"
    }
}

private struct Test: CustomStringConvertible {
    var name: String
    var status: TestStatus
    
    init(_ actionTestMetadata: ActionTestMetadata) {
        name = actionTestMetadata.name
        status = TestStatus(rawValue: actionTestMetadata.testStatus) ?? .unknown
    }
    
    var description: String {
        return "\(name): \(status.getValue)"
    }
}
