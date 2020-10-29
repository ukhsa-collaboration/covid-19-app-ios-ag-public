//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

private enum SummaryReportError: Error {
    case errorDecodingTestResults
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
    
}

extension Double {
    func rounded(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
