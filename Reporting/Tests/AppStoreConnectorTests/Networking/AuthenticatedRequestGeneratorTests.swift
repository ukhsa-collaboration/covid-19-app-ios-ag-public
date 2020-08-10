//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import AppStoreConnector

class AuthenticatedRequestGeneratorTests: XCTestCase {
    
    func testGeneratingAuthenticatedRequests() {
        let token = UUID().uuidString
        let generator = AuthenticatedRequestGenerator(host: "example.com", path: "/base") { token }
        let request = generator.request(for: "/resource")
        
        let url = URL(string: "https://example.com/base/resource")!
        var expectedRequest = URLRequest(url: url)
        expectedRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        XCTAssertEqual(request, expectedRequest)
    }
    
}
