//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation
import UIKit

@available(iOS 13.7, *)
struct ExposureWindowEventEndpoint: HTTPEndpoint {
    
    var riskInfo: ExposureRiskInfo
    var latestAppVersion: Version
    var postcode: String
    var hasPositiveTest: Bool
    
    func request(for input: ExposureNotificationExposureWindow) throws -> HTTPRequest {
        let payload = ExposureWindowEventPayload(window: input, hasPositiveTest: hasPositiveTest, riskInfo: riskInfo, latestAppliationVersion: latestAppVersion, postcode: postcode)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)
        return .post("/submission/mobile-analytics-events", body: .json(body))
    }
    
    func parse(_ response: HTTPResponse) throws {}
}

struct ExposureWindowEventPayload: Codable {
    struct Event: Codable {
        struct Payload: Codable {
            var testType: TestType?
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
        
        var type: EpidemiologicalEventType
        var version: Int
        var payload: Payload
    }
    
    struct Metadata: Codable {
        var operatingSystemVersion: String
        var latestApplicationVersion: String
        var deviceModel: String
        var postalDistrict: String
    }
    
    var metadata: Metadata
    var events: [Event]
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload {
    init(window: ExposureNotificationExposureWindow, hasPositiveTest: Bool, riskInfo: ExposureRiskInfo, latestAppliationVersion: Version, postcode: String) {
        let eventType = hasPositiveTest ? EpidemiologicalEventType.exposureWindowPostiveTest : EpidemiologicalEventType.exposureWindow
        let event = Event(type: eventType, version: 1, payload: Event.Payload(window: window, riskInfo: riskInfo, eventType: eventType))
        events = [event]
        metadata = Metadata(
            operatingSystemVersion: UIDevice.current.systemVersion,
            latestApplicationVersion: latestAppliationVersion.readableRepresentation,
            deviceModel: UIDevice.current.modelName,
            postalDistrict: postcode
        )
    }
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload.Event.Payload {
    init(window: ExposureNotificationExposureWindow, riskInfo: ExposureRiskInfo, eventType: EpidemiologicalEventType) {
        if eventType == .exposureWindowPostiveTest {
            testType = TestType.unknown
        }
        date = window.date
        infectiousness = ExposureWindowEventPayload.Event.Infectiousness(window.infectiousness)
        scanInstances = window.enScanInstances.map(ExposureWindowEventPayload.Event.ScanInstance.init)
        riskScore = riskInfo.riskScore
        riskCalculationVersion = riskInfo.riskScoreVersion
    }
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload.Event.Infectiousness {
    init(_ infectiousness: ENInfectiousness) {
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
extension ExposureWindowEventPayload.Event.ScanInstance {
    init(_ scanInstance: ExposureNotificationScanInstance) {
        minimumAttenuation = scanInstance.minimumAttenuation
        secondsSinceLastScan = scanInstance.secondsSinceLastScan
        typicalAttenuation = scanInstance.typicalAttenuation
    }
}
