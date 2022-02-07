//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Integration
import Localization
import Lokalise
import UIKit

@available(iOSApplicationExtension, unavailable)
public class MockScenario: Scenario {
    public static let name = "Mock"
    public static let nameForSorting = "0.2"
    public static let kind = ScenarioKind.environment
    
    static var description: String? {
        """
        An in-app mock server.
        You can use “Configure Mocks” home screen shortcut to modify server responses.
        """
    }
    
    static var appController: AppController {
        let server = MockServer(dataProvider: .shared)
        return CoordinatedAppController(developmentWith: .mock(with: server, copyServices: Environment.CopyServices(
            project: "895873615f401231224445.23171698",
            token: "7ef5472a38bba08d2d57cb3e1174687743d9e13f"
        )))
    }
}

@available(iOSApplicationExtension, unavailable)
private struct MockableApplication: Application {
    private var application: Application
    
    init(wrapping application: Application = SystemApplication()) {
        self.application = application
    }
    
    public var instanceOpenSettingsURLString: String {
        application.instanceOpenSettingsURLString
    }
    
    public var instanceOpenAppStoreURLString: String {
        application.instanceOpenAppStoreURLString
    }
    
    func open(_ url: URL, options: [OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
        // rather than have a separate key, just reuse the show keys one
        if MockDataProvider.shared.lokaliseShowKeysOnly {
            let alert = UIAlertController(title: "URL", message: url.absoluteString, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            application.open(url, options: options, completionHandler: completion)
        }
    }
}

private struct MockableCameraManager: CameraManaging {
    let cameraManager = CameraManager()
    let mockCameraManager = MockCameraManager(authorizationStatus: .authorized)
    
    var instanceAuthorizationStatus: AuthorizationStatus {
        if MockDataProvider.shared.useFakeCheckins {
            return mockCameraManager.instanceAuthorizationStatus
        } else {
            return cameraManager.instanceAuthorizationStatus
        }
    }
    
    func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        if MockDataProvider.shared.useFakeCheckins {
            mockCameraManager.requestAccess(completionHandler: handler)
        } else {
            cameraManager.requestAccess(completionHandler: handler)
        }
    }
    
    func createCaptureSession(handler: CaptureSessionOutputHandler) -> CaptureSession? {
        if MockDataProvider.shared.useFakeCheckins {
            return mockCameraManager.createCaptureSession(handler: handler)
        } else {
            return cameraManager.createCaptureSession(handler: handler)
        }
    }
}

private struct MockableVenueDecoder: VenueDecoding {
    let venueDecoder: VenueDecoding
    let mockVenueDecoder = MockVenueDecoder()
    
    func decode(_ payload: String) throws -> [Venue] {
        if MockDataProvider.shared.useFakeCheckins {
            MockDataProvider.shared.useFakeCheckins = false // automatically toggle the switch off after scanning the mock venue
            return try mockVenueDecoder.decode(payload)
        } else {
            return try venueDecoder.decode(payload)
        }
    }
}

private extension ApplicationServices {
    
    @available(iOSApplicationExtension, unavailable)
    private convenience init(simulatedENServicesFor environment: Environment) {
        let dateProvider = AdjustableDateProvider()
        let bluetoothEnabled = MockDataProvider.shared.objectWillChange
            .map { _ in MockDataProvider.shared.bluetoothEnabled }
            .prepend(MockDataProvider.shared.bluetoothEnabled)
            .eraseToAnyPublisher()
        
        self.init(
            standardServicesFor: environment,
            dateProvider: dateProvider,
            riskyPostcodeUpdateIntervalProvider: RiskyPostcodeAdjustableMinimumUpdateIntervalProvider(),
            exposureNotificationManager: SimulatedExposureNotificationManager(dateProvider: dateProvider, bluetoothEnabled: bluetoothEnabled),
            cameraManager: MockableCameraManager(),
            venueDecoder: MockableVenueDecoder(venueDecoder: environment.venueDecoder),
            application: MockableApplication()
        )
    }
    
    @available(iOSApplicationExtension, unavailable)
    convenience init(developmentServicesFor environment: Environment) {
        let dateProvider = AdjustableDateProvider()
        
        #if targetEnvironment(simulator)
        self.init(simulatedENServicesFor: environment)
        #else
        if MockDataProvider.shared.useFakeENContacts {
            self.init(simulatedENServicesFor: environment)
        } else {
            self.init(
                standardServicesFor: environment,
                dateProvider: dateProvider,
                riskyPostcodeUpdateIntervalProvider: RiskyPostcodeAdjustableMinimumUpdateIntervalProvider(),
                cameraManager: MockableCameraManager(),
                venueDecoder: MockableVenueDecoder(venueDecoder: environment.venueDecoder),
                application: MockableApplication()
            )
        }
        #endif
    }
    
}

@available(iOSApplicationExtension, unavailable)
extension CoordinatedAppController {
    
    convenience init(developmentWith environment: Environment) {
        let enabledFeatures = FeatureToggleStorage.getEnabledFeatures()
        let services = ApplicationServices(developmentServicesFor: environment)
        self.init(services: services, enabledFeatures: enabledFeatures)
        
        if let copyServices = environment.copyServices {
            Lokalise.shared.setProjectID(copyServices.project, token: copyServices.token)
            Lokalise.shared.localizationType = .prerelease
            Localization.current.overrider = LokaliseOverrider()
        }
    }
    
}
