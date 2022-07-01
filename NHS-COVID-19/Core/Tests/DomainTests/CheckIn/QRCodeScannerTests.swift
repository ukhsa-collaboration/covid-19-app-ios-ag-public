//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class QRCodeScannerTests: XCTestCase {
    private var cancellables = [AnyCancellable]()

    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var cameraManager = MockCameraManager()
            var notificationCenter = NotificationCenter()

        }

        var scanner: QRCodeScanner
        var cameraStateController: CameraStateController

        init(configuration: Configuration) {
            cameraStateController = CameraStateController(
                manager: configuration.cameraManager,
                notificationCenter: configuration.notificationCenter
            )
            scanner = QRCodeScanner(
                cameraManager: configuration.cameraManager,
                cameraStateController: cameraStateController
            )
        }
    }

    @Propped
    private var instance: Instance

    private var scanner: QRCodeScanner {
        instance.scanner
    }

    private var cameraManager: MockCameraManager {
        $instance.cameraManager
    }

    private var cameraStateController: CameraStateController {
        instance.cameraStateController
    }

    func testInitialState() {
        XCTAssertEqual(QRCodeScannerState.starting, scanner.state)
    }

    func testStates() throws {
//        cameraManager.instanceAuthorizationStatus = .authorized
//        scanner.startScanner(targetView: UIView(), scanViewBounds: CGRect(), resultHandler: {_ in })
//
//        let expectedStates: [QRCodeScannerState] = [.starting, .requestingPermission, .running]
//        var stateIdx = 0
//
//        scanner.$state.sink { value in
//            if value != expectedStates[stateIdx] {
//                XCTFail("State(\(value)) did not match expected state(\(expectedStates[stateIdx])")
//            }
//            stateIdx += 1
//        }.store(in: &cancellables)
    }
}
