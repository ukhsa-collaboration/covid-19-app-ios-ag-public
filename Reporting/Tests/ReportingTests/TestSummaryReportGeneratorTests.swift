//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Reporting

final class TestSummaryReportGeneratorTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
    }
    
    func testCreatingCoverageSummaryWithCorrectFormat() throws {
        let sut = TestSummaryReportGenerator()
        let coverageData = try sut.createCoverageSummary(from: getTestResultsJSON)
        let result = String(data: coverageData, encoding: .utf8)!
        
        let expectedCoverageOutput = """
        General:
        ========
        
        Type of coverage used: branch coverage
        
        Coverages of modules:
        =====================
        
        Domain: 86.62%
        Integration: 69.06%
        Localization: 74.13%
        Interface: 85.48%
        Common: 61.92%
        
        Total test coverage: 82.3%
        """
        
        XCTAssertEqual(result, expectedCoverageOutput)
    }
    
    func testCreatingCoverageSummaryMissingTarget() throws {
        let sut = TestSummaryReportGenerator()
        
        let json = """
        {
          "coveredLines" : 31855,
          "lineCoverage" : 0.55645809314187888,
          "targets" : [
            {
              "coveredLines" : 4459,
              "lineCoverage" : 0.86616161616161613,
              "name" : "Domain",
              "executableLines" : 5148,
              "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Domain.o"
            },
            {
              "coveredLines" : 1136,
              "lineCoverage" : 0.69057750759878422,
              "name" : "Integration",
              "executableLines" : 1645,
              "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Integration.o"
            },
          ],
          "executableLines" : 57246
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try sut.createCoverageSummary(from: json))
    }
    
}

private var getTestResultsJSON: Data {
    let json = """
    {
      "coveredLines" : 31855,
      "lineCoverage" : 0.55645809314187888,
      "targets" : [
        {
          "coveredLines" : 4459,
          "lineCoverage" : 0.86616161616161613,
          "name" : "Domain",
          "executableLines" : 5148,
          "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Domain.o"
        },
        {
          "coveredLines" : 1136,
          "lineCoverage" : 0.69057750759878422,
          "name" : "Integration",
          "executableLines" : 1645,
          "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Integration.o"
        },
        {
          "coveredLines" : 192,
          "lineCoverage" : 0.74131274131274127,
          "name" : "Localization",
          "executableLines" : 259,
          "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Localization.o"
        },
        {
          "coveredLines" : 6616,
          "lineCoverage" : 0.85478036175710592,
          "name" : "Interface",
          "executableLines" : 7740,
          "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Interface.o"
        },
        {
          "coveredLines" : 696,
          "lineCoverage" : 0.61921708185053381,
          "name" : "Common",
          "executableLines" : 1124,
          "buildProductPath" : "/Users/runner/Library/Developer/Xcode/DerivedData/NHS-COVID-19-dfnuonamlwfjwgfmawgkjdetmvgt/Build/Products/Debug-iphonesimulator/Common.o"
        }
      ],
      "executableLines" : 57246
    }
    """
    return json.data(using: .utf8)!
}
