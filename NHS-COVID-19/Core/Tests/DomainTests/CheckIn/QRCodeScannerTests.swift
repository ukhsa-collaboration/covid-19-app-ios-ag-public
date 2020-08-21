//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Scenarios
import XCTest
@testable import Domain

class QRCodeScannerTests: XCTestCase {
    
    func testCreateCaptureSession() {
        let cameraManager = MockCameraManager()
        let scanner = QRCodeScanner(cameraManager: cameraManager)
        let resultHandler: ([AVMetadataMachineReadableCodeObject]) -> Void = { _ in }
        _ = scanner.createCaptureSession(resultHandler: resultHandler)
        
        XCTAssertNotNil(cameraManager.receivedHandler?.handleOutput)
    }
}
