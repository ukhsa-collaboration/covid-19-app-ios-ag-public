//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
@testable import Domain
@testable import Scenarios

struct TestOrdering {
    
    private let apiClient: MockHTTPClient
    private let virologyManager: VirologyTestingManaging
    
    init(configuration: AcceptanceTestCase.Instance.Configuration, context: RunningAppContext) {
        self.apiClient = configuration.apiClient
        self.virologyManager = context.virologyTestingManager
    }
    
    func order() throws {
        apiClient.response(for: "/virology-test/home-kit/order", response: .success(.ok(with: .json(orderTestkitResponse))))
        _ = try virologyManager.provideTestOrderInfo().await()
    }
}

private let orderTestkitResponse = """
{
    "websiteUrlWithQuery": "https://self-referral.test-for-coronavirus.service.gov.uk/cta-start?ctaToken=tbdfjaj0",
    "tokenParameterValue": "tbdfjaj0",
    "testResultPollingToken" : "61EEFD4B-E903-4294-B595-B1D491134E3D",
    "diagnosisKeySubmissionToken": "6B162698-ADC5-47AF-8790-71ACF770FFAF"
}
"""
