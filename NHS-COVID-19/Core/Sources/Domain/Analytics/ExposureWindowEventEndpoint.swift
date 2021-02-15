//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation
import UIKit

@available(iOS 13.7, *)
struct ExposureWindowEventEndpoint: HTTPEndpoint {
    
    var latestAppVersion: Version
    var postcode: String
    var localAuthority: String
    var eventType: EpidemiologicalEventType
    
    func request(for input: ExposureWindowInfo) throws -> HTTPRequest {
        let payload = ExposureWindowEventPayload(
            window: input,
            eventType: eventType,
            latestAppliationVersion: latestAppVersion,
            postcode: postcode,
            localAuthority: localAuthority
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)
        return .post("/submission/mobile-analytics-events", body: .json(body))
    }
    
    func parse(_ response: HTTPResponse) throws {}
}

private struct ExposureWindowEventPayload: Codable {
    struct Event: Codable {
        enum EventType: String, Codable {
            case exposureWindow
            case exposureWindowPositiveTest
            
            init(_ type: EpidemiologicalEventType) {
                switch type {
                case .exposureWindow: self = .exposureWindow
                case .exposureWindowPositiveTest: self = .exposureWindowPositiveTest
                }
            }
        }
        
        enum TestType: String, Codable {
            case unknown
            case labResult = "LAB_RESULT"
            case rapidResult = "RAPID_RESULT"
            case rapidSelfReported = "RAPID_SELF_REPORTED"
            
            init(_ testKitType: TestKitType?) {
                switch testKitType {
                case .labResult: self = .labResult
                case .rapidResult: self = .rapidResult
                case .rapidSelfReported: self = .rapidSelfReported
                case .none: self = .unknown
                }
            }
        }
        
        struct Payload: Codable {
            var testType: TestType?
            var requiresConfirmatoryTest: Bool?
            var date: Date
            var infectiousness: Infectiousness
            var scanInstances: [ScanInstance]
            var riskScore: Double
            var riskCalculationVersion: Int
        }
        
        struct ScanInstance: Codable {
            var minimumAttenuation: UInt8
            var typicalAttenuation: UInt8
            var secondsSinceLastScan: Int
        }
        
        enum Infectiousness: String, Codable {
            case none
            case standard
            case high
        }
        
        var type: EventType
        var version: Int
        var payload: Payload
    }
    
    struct Metadata: Codable {
        var operatingSystemVersion: String
        var latestApplicationVersion: String
        var deviceModel: String
        var postalDistrict: String
        var localAuthority: String
    }
    
    var metadata: Metadata
    var events: [Event]
}

@available(iOS 13.7, *)
private extension ExposureWindowEventPayload {
    init(window: ExposureWindowInfo, eventType: EpidemiologicalEventType, latestAppliationVersion: Version, postcode: String, localAuthority: String) {
        let event = Event(
            type: .init(eventType),
            version: eventType.version,
            payload: Event.Payload(window: window, eventType: eventType)
        )
        events = [event]
        metadata = Metadata(
            operatingSystemVersion: UIDevice.current.systemVersion,
            latestApplicationVersion: latestAppliationVersion.readableRepresentation,
            deviceModel: UIDevice.current.modelName,
            postalDistrict: postcode,
            localAuthority: localAuthority
        )
    }
}

private extension EpidemiologicalEventType {
    
    var version: Int {
        switch self {
        case .exposureWindow:
            return 1
        case .exposureWindowPositiveTest:
            return 2
        }
    }
    
}

@available(iOS 13.7, *)
private extension ExposureWindowEventPayload.Event.Payload {
    init(window: ExposureWindowInfo, eventType: EpidemiologicalEventType) {
        switch eventType {
        case .exposureWindowPositiveTest(let testKitType, let requiresConfirmatoryTest):
            testType = .init(testKitType)
            self.requiresConfirmatoryTest = requiresConfirmatoryTest
        case .exposureWindow:
            testType = nil
            requiresConfirmatoryTest = nil
        }
        date = window.date.startDate(in: .utc)
        infectiousness = ExposureWindowEventPayload.Event.Infectiousness(window.infectiousness)
        scanInstances = window.scanInstances.map(ExposureWindowEventPayload.Event.ScanInstance.init)
        riskScore = window.riskScore
        riskCalculationVersion = window.riskCalculationVersion
    }
}

@available(iOS 13.7, *)
private extension ExposureWindowEventPayload.Event.Infectiousness {
    init(_ infectiousness: ExposureWindowInfo.Infectiousness) {
        switch infectiousness {
        case .none:
            self = .none
        case .standard:
            self = .standard
        case .high:
            self = .high
        @unknown default:
            self = .none
        }
    }
}

@available(iOS 13.7, *)
private extension ExposureWindowEventPayload.Event.ScanInstance {
    init(_ scanInstance: ExposureWindowInfo.ScanInstance) {
        minimumAttenuation = scanInstance.minimumAttenuation
        secondsSinceLastScan = scanInstance.secondsSinceLastScan
        typicalAttenuation = scanInstance.typicalAttenuation
    }
}
