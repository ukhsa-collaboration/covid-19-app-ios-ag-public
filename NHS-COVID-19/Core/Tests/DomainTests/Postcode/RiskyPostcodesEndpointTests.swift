//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class RiskyPostcodesEndpointTests: XCTestCase {
    
    let endpoint = RiskyPostcodesEndpointV2()
    
    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/risky-post-districts-v2")
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingEmptyList() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "postDistricts" : {},
            "riskLevels": {}
        }
        """#))
        
        let riskyPostcodes = try endpoint.parse(response)
        
        XCTAssert(riskyPostcodes.isEmpty)
    }
    
    func testDecodingListWithPostcodes() throws {
        let postcode1 = String.random()
        let postcode2 = String.random()
        let postcode3 = String.random()
        
        let riskIndicator1 = String.random()
        let riskIndicator2 = String.random()
        let riskIndicator3 = String.random()
        
        let response = HTTPResponse.ok(with: .json("""
        {
            "postDistricts": {
                "\(postcode1)": "\(riskIndicator1)",
                "\(postcode2)": "\(riskIndicator2)",
                "\(postcode3)": "\(riskIndicator3)"
            },
            "riskLevels": {
                "\(riskIndicator1)": {
                    "colorScheme": "green",
                    "name": {
                        "en": "Tier 2"
                    },
                    "heading": {
                        "en": "Data from NHS shows…"
                    },
                    "content": {
                        "en": "Your local authority…"
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://gov.uk/somewhere"
                    }
                }
            }
        }
        """))
        
        let riskyPostcodes = try endpoint.parse(response)
        
        let expected = RiskyPostcodes.RiskStyle(
            colorScheme: .green,
            name: [Locale(identifier: "en"): "Tier 2"],
            heading: [Locale(identifier: "en"): "Data from NHS shows…"],
            content: [Locale(identifier: "en"): "Your local authority…"],
            linkTitle: [Locale(identifier: "en"): "Restrictions in your area"],
            linkUrl: [Locale(identifier: "en"): "https://gov.uk/somewhere"]
        )
        
        TS.assert(riskyPostcodes.riskStyle(for: Postcode(postcode1))?.style, equals: expected)
        TS.assert(riskyPostcodes.riskStyle(for: Postcode(postcode1))?.id, equals: riskIndicator1)
        XCTAssertNil(riskyPostcodes.riskStyle(for: Postcode(postcode2)))
        XCTAssertNil(riskyPostcodes.riskStyle(for: Postcode(postcode3)))
    }
    
    func testDecodingListWithPolicyData() throws {
        let postcode1 = String.random()
        let postcode2 = String.random()
        let postcode3 = String.random()
        
        let riskIndicator1 = String.random()
        let riskIndicator2 = String.random()
        let riskIndicator3 = String.random()
        
        let response = HTTPResponse.ok(with: .json("""
        {
            "postDistricts": {
                "\(postcode1)": "\(riskIndicator1)",
                "\(postcode2)": "\(riskIndicator2)",
                "\(postcode3)": "\(riskIndicator3)"
            },
            "riskLevels": {
                "\(riskIndicator1)": {
                    "colorScheme": "green",
                    "name": {
                        "en": "Tier 2"
                    },
                    "heading": {
                        "en": "Data from NHS shows…"
                    },
                    "content": {
                        "en": "Your local authority…"
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://gov.uk/somewhere"
                    },
                    "policyData": {
                        "localAuthorityRiskTitle": {
                            "en": "Tier 2"
                        },
                        "heading": {
                            "en": "Your area has coronavirus…"
                        },
                        "content": {
                            "en": "Your area is inline…"
                        },
                        "footer": {
                            "en": "Find out more…"
                        },
                        "policies": [
                            {
                                "policyIcon": "meetingPeople",
                                "policyHeading": {
                                    "en": "Meeting people",
                                },
                                "policyContent": {
                                    "en": "Meeting people",
                                },
                            },
                            {
                                "policyIcon": "bars",
                                "policyHeading": {
                                    "en": "Bars and pubs",
                                },
                                "policyContent": {
                                    "en": "Venues must close…",
                                }
                            },
                        ]
                    }
                }
            }
        }
        """))
        
        let riskyPostcodes = try endpoint.parse(response)
        
        let expected = RiskyPostcodes.RiskStyle(
            colorScheme: .green,
            name: [Locale(identifier: "en"): "Tier 2"],
            heading: [Locale(identifier: "en"): "Data from NHS shows…"],
            content: [Locale(identifier: "en"): "Your local authority…"],
            linkTitle: [Locale(identifier: "en"): "Restrictions in your area"],
            linkUrl: [Locale(identifier: "en"): "https://gov.uk/somewhere"],
            policyData: RiskyPostcodes.PolicyData(
                localAuthorityRiskTitle: [Locale(identifier: "en"): "Tier 2"],
                heading: [Locale(identifier: "en"): "Your area has coronavirus…"],
                content: [Locale(identifier: "en"): "Your area is inline…"],
                footer: [Locale(identifier: "en"): "Find out more…"],
                policies: [
                    RiskyPostcodes.Policy(
                        policyIcon: "meetingPeople",
                        policyHeading: [Locale(identifier: "en"): "Meeting people"],
                        policyContent: [Locale(identifier: "en"): "Meeting people"]
                    ),
                    RiskyPostcodes.Policy(
                        policyIcon: "bars",
                        policyHeading: [Locale(identifier: "en"): "Bars and pubs"],
                        policyContent: [Locale(identifier: "en"): "Venues must close…"]
                    ),
                ]
            )
        )
        
        TS.assert(riskyPostcodes.riskStyle(for: Postcode(postcode1))?.style, equals: expected)
        TS.assert(riskyPostcodes.riskStyle(for: Postcode(postcode1))?.id, equals: riskIndicator1)
        XCTAssertNil(riskyPostcodes.riskStyle(for: Postcode(postcode2)))
        XCTAssertNil(riskyPostcodes.riskStyle(for: Postcode(postcode3)))
    }
}
