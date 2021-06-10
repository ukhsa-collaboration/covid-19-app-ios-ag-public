//
// Copyright © 2021 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class LocalInformationEndpointTests: XCTestCase {
    
    let endpoint = LocalInformationEndpoint()
    
    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/local-messages")
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingEmptyList() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {},
            "messages": {}
        }
        """#))
        
        let localMessages = try endpoint.parse(response)
        
        XCTAssert(localMessages.isEmpty)
    }

    func testDecodingSingleMessage() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {"ABCD1234": ["message1"]},
            "messages": {
              "message1": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        }
                     ]
                   }
                }
            }
           }
        }
        """#))
        
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty)
        
        let message = localMessages.message(for: LocalAuthorityId("ABCD1234"))
        XCTAssert(message?.message.contentVersion == 1)
        // todo; check payload

        XCTAssertNil(localMessages.message(for: LocalAuthorityId("ABCD9876")))
    }
    
    func testDecodingMultipleMessage() throws {
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {
               "ABCD1234": ["message1"],
               "ABCD19876": ["message2"]
            },
            "messages": {
              "message1": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        }
                     ]
                   }
                }
            },
            "message2": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the second header text",
                    "body": "this is the second body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "This is the second additional info",
                        }
                     ]
                   }
                }
            }
           }
        }
        """#))
        
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty)
        
        let message1 = localMessages.message(for: LocalAuthorityId("ABCD1234"))?.message
        XCTAssertEqual(message1?.translations(for: "en")?.blocks()?.first?.text, "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe")
        XCTAssertNotNil(message1?.translations(for: "en")?.blocks()?.first?.url)

        let message2 = localMessages.message(for: LocalAuthorityId("ABCD19876"))?.message
        XCTAssertEqual(message2?.translations(for: "en")?.blocks()?.first?.text, "This is the second additional info")
        XCTAssertNil(message2?.translations(for: "en")?.blocks()?.first?.url)
    }
    
    func testDecodingMultipleMessageWithWildcard() throws {
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {
               "ABCD1234": ["message1"],
               "ABCD19876": ["message2"],
               "*": ["message3"]
            },
            "messages": {
              "message1": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        }
                     ]
                   }
                }
            },
            "message2": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the second header text",
                    "body": "this is the second body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "This is the second additional info",
                        }
                     ]
                   }
                }
            },
            "message3": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the third header text",
                    "body": "this is the third body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "This is the wildcard additional info",
                        }
                     ]
                   }
                }
            }
           }
        }
        """#))
        
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty)
        
        let message1 = localMessages.message(for: LocalAuthorityId("ABCD1234"))?.message
        XCTAssertEqual(message1?.translations(for: "en")?.blocks()?.first?.text, "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe")
        XCTAssertNotNil(message1?.translations(for: "en")?.blocks()?.first?.url)

        let message2 = localMessages.message(for: LocalAuthorityId("ABCD19876"))?.message
        XCTAssertEqual(message2?.translations(for: "en")?.blocks()?.first?.text, "This is the second additional info")
        XCTAssertNil(message2?.translations(for: "en")?.blocks()?.first?.url)

        let message3 = localMessages.message(for: LocalAuthorityId("E0001239"))?.message
        XCTAssertEqual(message3?.translations(for: "en")?.blocks()?.first?.text, "This is the wildcard additional info")
        XCTAssertNil(message3?.translations(for: "en")?.blocks()?.first?.url)

        let message3v2 = localMessages.message(for: LocalAuthorityId("LA123456"))?.message
        XCTAssertEqual(message3v2?.translations(for: "en")?.blocks()?.first?.text, "This is the wildcard additional info")
        XCTAssertNil(message3v2?.translations(for: "en")?.blocks()?.first?.url)
    }

    func testDecodingMessageWithUnknownBlocks() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {"ABCD1234": ["message1"]},
            "messages": {
              "message1": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        },
                        {
                            "type": "icon-para",
                            "text": "This is some more text in another layout",
                            "text2": "This is some more text in another layout",
                            "icon": "thermometer"
                        }
                     ]
                   }
                }
            }
           }
        }
        """#))
        
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty)
        
        let message1 = localMessages.message(for: LocalAuthorityId("ABCD1234"))?.message
        let messageBlocks = message1?.translations(for: "en")?.blocks()
        XCTAssertTrue(messageBlocks?.count == 1)
        XCTAssertEqual(messageBlocks?.first?.text, "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe")

        XCTAssertNil(localMessages.message(for: LocalAuthorityId("ABCD9876")))
    }
    
    func testDecodingMessageWithUnknownType() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {"ABCD1234": ["message1"]},
            "messages": {
              "message1": {
                "type": "extended-notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        }
                     ]
                   }
                }
            }
           }
        }
        """#))
        
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty) // hmm
        
        let message1 = localMessages.message(for: LocalAuthorityId("ABCD1234"))
        XCTAssertNil(message1)
    }

    func testDecodingMessageWithMultipleLanguages() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {"ABCD1234": ["message1"]},
            "messages": {
              "message1": {
                "type": "notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        }
                     ]
                   },
                  "ar": {
                    "head": "this is the header text in arabic",
                    "body": "this is the body text in arabic",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe in arabic",
                            "link": "http://example.com",
                            "linkText": "Click me in arabic"
                        }
                     ]
                   }
                }
                }
            }
        }
        """#))
                
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty)
        
        let message1 = localMessages.message(for: LocalAuthorityId("ABCD1234"))?.message
        
        // picks up the en version
        let enMessageBlocks = message1?.translations(for: "en")?.blocks()
        XCTAssertTrue(enMessageBlocks?.count == 1)
        XCTAssertEqual(enMessageBlocks?.first?.text, "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe")
        XCTAssertNotNil(enMessageBlocks?.first?.url)

        // picks up the ar version
        let arMessageBlocks = message1?.translations(for: "ar")?.blocks()
        XCTAssertTrue(arMessageBlocks?.count == 1)
        XCTAssertEqual(arMessageBlocks?.first?.text, "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe in arabic")
        XCTAssertNotNil(arMessageBlocks?.first?.url)
        
        // default to en
        let cnMessageBlocks = message1?.translations(for: "cn")?.blocks()
        XCTAssertTrue(cnMessageBlocks?.count == 1)
        XCTAssertEqual(cnMessageBlocks?.first?.text, "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe")
        XCTAssertNotNil(cnMessageBlocks?.first?.url)
    }
    
    func testDecodingMessageWithUnknownStructure() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "las" : {"ABCD1234": ["message1"]},
            "messages": {
              "message1": {
                "type": "extended-notification",
                "updated": "2021-05-19T14:59:13+00:00",
                "contentVersion": 1,
                "translations": {
                  "en": {
                    "head": "this is the header text",
                    "body": "this is the body text",
                    "content": [
                        {
                            "type": "unknown-thing",
                            "text123": "There have been reported cases of a new variant in {postcode}. Here are some key pieces of information to help you stay safe",
                            "link123": "http://example.com",
                            "linkText123": "Click me"
                        }
                     ]
                   }
                }
            }
           }
        }
        """#))
        
        let localMessages = try endpoint.parse(response)

        XCTAssertFalse(localMessages.isEmpty) // hmm
        
        let message1 = localMessages.message(for: LocalAuthorityId("ABCD1234"))
        XCTAssertNil(message1)
    }
}
