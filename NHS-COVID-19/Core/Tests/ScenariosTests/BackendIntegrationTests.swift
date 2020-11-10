//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import ProductionConfiguration
import Scenarios
import ScenariosConfiguration
import TestSupport
import XCTest
@testable import Domain
@testable import Integration

class BackendIntegrationTests: XCTestCase {
    
    private var distributionClient: HTTPClient!
    private var submissionclient: HTTPClient!
    
    override func setUp() {
        super.setUp()
        
        let configuration = EnvironmentConfiguration.test
        distributionClient = AppHTTPClient(for: configuration.distributionRemote, kind: .distribution)
        submissionclient = AppHTTPClient(for: configuration.submissionRemote, kind: .submission(userAgentHeaderValue: "p=iOS,o=14.0.1,v=3.8,b=229"))
    }
    
    fileprivate func runDistributionTest<T: HTTPEndpoint, ResultType>(with endpoint: T, expectedType: ResultType.Type) throws where T.Input == Void, T.Output == ResultType {
        let result = try distributionClient.fetch(endpoint).await(timeout: 5).get()
        print(result)
    }
    
    fileprivate func runSubmissionTest<T: HTTPEndpoint, InputType, ResultType>(with endpoint: T, input: InputType, expectedType: ResultType.Type) throws where T.Input == InputType, T.Output == ResultType {
        let result = try submissionclient.fetch(endpoint, with: input).await(timeout: 5).get()
        print(result)
    }
    
    fileprivate func runSubmissionTest<T: HTTPEndpoint, ResultType>(with endpoint: T, expectedType: ResultType.Type) throws where T.Input == Void, T.Output == ResultType {
        let result = try submissionclient.fetch(endpoint).await(timeout: 5).get()
        print(result)
    }
}

extension BackendIntegrationTests {
    func _testRiskyPostcodes() throws {
        try runDistributionTest(with: RiskyPostcodesEndpointV2(), expectedType: RiskyPostcodes.self)
    }
}

extension BackendIntegrationTests {
    func _testRiskyVenues() throws {
        try runDistributionTest(with: RiskyVenuesEndpoint(), expectedType: [RiskyVenue].self)
    }
}

extension BackendIntegrationTests {
    func _testExposureRiskConfiguration() throws {
        try runDistributionTest(with: ExposureNotificationConfigurationEndPoint(), expectedType: ExposureDetectionConfiguration.self)
    }
}

extension BackendIntegrationTests {
    func _testOrderTestKit() throws {
        try runSubmissionTest(with: OrderTestkitEndpoint(), expectedType: OrderTestkitResponse.self)
    }
}

extension BackendIntegrationTests {
    func _testDiagnosisKeySubmission() throws {
        let result = try submissionclient.fetch(OrderTestkitEndpoint()).await(timeout: 5).get()
        let diagnosisKeySubmissionToken = result.diagnosisKeySubmissionToken
        let keys = [
            TemporaryExposureKey(exposureKey: ENTemporaryExposureKey(), onsetDay: .today),
            TemporaryExposureKey(exposureKey: ENTemporaryExposureKey(), onsetDay: .today),
        ]
        try runSubmissionTest(with: DiagnosisKeySubmissionEndPoint(token: diagnosisKeySubmissionToken), input: keys, expectedType: Void.self)
    }
}

extension BackendIntegrationTests {
    func _testDailyKeysDownload() throws {
        let detectionClient = ExposureDetectionEndpointManager(
            distributionClient: distributionClient,
            fileStorage: FileStorage(forCachesOf: .random())
        )
        
        let zipManager = try detectionClient.getExposureKeys(for: .daily(.today)).await(timeout: 5).get()
        let fileManager = FileManager()
        let handler = try zipManager.extract(fileManager: fileManager)
        let urls = try fileManager.contentsOfDirectory(
            at: handler.folderURL,
            includingPropertiesForKeys: nil
        ).map { $0.absoluteString }
        XCTAssert(urls.contains { $0.hasSuffix("export.bin") })
        XCTAssert(urls.contains { $0.hasSuffix("export.sig") })
    }
    
    func _testHourlyKeysDownload() throws {
        let detectionClient = ExposureDetectionEndpointManager(
            distributionClient: distributionClient,
            fileStorage: FileStorage(forCachesOf: .random())
        )
        let zipManager = try detectionClient.getExposureKeys(for: .twoHourly(.today, .init(value: 0))).await(timeout: 5).get()
        let fileManager = FileManager()
        let handler = try zipManager.extract(fileManager: fileManager)
        let urls = try fileManager.contentsOfDirectory(
            at: handler.folderURL,
            includingPropertiesForKeys: nil
        ).map { $0.absoluteString }
        XCTAssert(urls.contains { $0.hasSuffix("export.bin") })
        XCTAssert(urls.contains { $0.hasSuffix("export.sig") })
    }
}

private extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}

private extension Data {
    var asString: String? {
        String(data: self, encoding: .utf8)
    }
}
