//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct RiskyPostcodesEndpointV2: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/risky-post-districts-v2")
    }
    
    func parse(_ response: HTTPResponse) throws -> RiskyPostcodes {
        return try JSONDecoder().decode(RiskyPostcodes.self, from: response.body.content)
    }
    
}

public struct RiskyPostcodes: Decodable {
    var postDistricts: PostDistricts
    var localAuthorities: LocalAuthorities?
    var riskLevels: RiskLevels
    
    func riskStyle(for postcode: Postcode) -> (id: String, style: RiskStyle)? {
        guard let riskIndicator = postDistricts[postcode] else { return nil }
        return riskLevels[riskIndicator].map { (riskIndicator.value, $0) }
    }
    
    func riskStyle(for localAuthority: LocalAuthorityId) -> (id: String, style: RiskStyle)? {
        guard let riskIndicator = localAuthorities?[localAuthority] else { return nil }
        return riskLevels[riskIndicator].map { (riskIndicator.value, $0) }
    }
    
    var isEmpty: Bool {
        return postDistricts.isEmpty && riskLevels.isEmpty
    }
}

extension RiskyPostcodes {
    public struct PostDistricts: ExpressibleByDictionaryLiteral {
        private var values: [Postcode: RiskIndicator]
        
        public init(dictionaryLiteral elements: (Postcode, RiskyPostcodes.RiskIndicator)...) {
            values = Dictionary(elements, uniquingKeysWith: { $1 })
        }
        
        subscript(_ postcode: Postcode) -> RiskIndicator? {
            values[postcode]
        }
        
        var isEmpty: Bool {
            values.isEmpty
        }
    }
    
    public struct LocalAuthorities: ExpressibleByDictionaryLiteral {
        private var values: [LocalAuthorityId: RiskIndicator]
        
        public init(dictionaryLiteral elements: (LocalAuthorityId, RiskyPostcodes.RiskIndicator)...) {
            values = Dictionary(elements, uniquingKeysWith: { $1 })
        }
        
        subscript(_ localAuthority: LocalAuthorityId) -> RiskIndicator? {
            values[localAuthority]
        }
        
        var isEmpty: Bool {
            values.isEmpty
        }
    }
}

extension RiskyPostcodes.PostDistricts: Decodable {
    // Synthesised Decodable conformance doesn't work with custom keys in dictionaries
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValues = try container.decode([String: RiskyPostcodes.RiskIndicator].self)
        values = Dictionary(uniqueKeysWithValues: stringValues.map { key, value in
            (Postcode(key), value)
        })
    }
}

extension RiskyPostcodes.LocalAuthorities: Decodable {
    // Synthesised Decodable conformance doesn't work with custom keys in dictionaries
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValues = try container.decode([String: RiskyPostcodes.RiskIndicator].self)
        values = Dictionary(uniqueKeysWithValues: stringValues.map { key, value in
            (LocalAuthorityId(key), value)
        })
    }
}

extension RiskyPostcodes {
    struct RiskLevels: ExpressibleByDictionaryLiteral {
        private var values: [RiskIndicator: RiskStyle]
        
        public init(dictionaryLiteral elements: (RiskIndicator, RiskStyle)...) {
            values = Dictionary(elements, uniquingKeysWith: { $1 })
        }
        
        subscript(_ riskIndicator: RiskIndicator) -> RiskStyle? {
            values[riskIndicator]
        }
        
        var isEmpty: Bool {
            values.isEmpty
        }
    }
}

extension RiskyPostcodes.RiskLevels: Decodable {
    // Synthesised Decodable conformance doesn't work with custom keys in dictionaries
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValues = try container.decode([String: RiskyPostcodes.RiskStyle].self)
        values = Dictionary(uniqueKeysWithValues: stringValues.map { key, value in
            (RiskyPostcodes.RiskIndicator(value: key), value)
        })
    }
}

extension RiskyPostcodes {
    public struct RiskIndicator: Hashable {
        var value: String
    }
}

extension RiskyPostcodes.RiskIndicator: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(String.self)
    }
}

extension RiskyPostcodes {
    public struct RiskStyle: Decodable, Equatable {
        public enum ColorScheme: String, Codable {
            case green, amber, yellow, red, neutral
        }
        
        public var colorScheme: ColorScheme
        public var name: LocaleString
        public var heading: LocaleString
        public var content: LocaleString
        public var linkTitle: LocaleString
        public var linkUrl: LocaleString
        public var policyData: PolicyData?
    }
    
    public struct PolicyData: Decodable, Equatable {
        public var localAuthorityRiskTitle: LocaleString
        public var heading: LocaleString
        public var content: LocaleString
        public var footer: LocaleString
        public var policies: [Policy]
    }
    
    public struct Policy: Decodable, Equatable {
        public var policyIcon: String
        public var policyHeading: LocaleString
        public var policyContent: LocaleString
    }
}
