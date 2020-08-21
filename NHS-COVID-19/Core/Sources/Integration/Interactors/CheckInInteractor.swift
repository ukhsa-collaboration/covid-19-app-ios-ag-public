//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Foundation
import Interface
import UIKit

struct CheckInInteractor: CheckInFlowViewController.Interacting {
    
    var _openSettings: () -> Void
    var _requestCameraAccess: () -> Void
    var _createCaptureSession: (@escaping ([AVMetadataMachineReadableCodeObject]) -> Void) -> AVCaptureSession?
    var _process: (String) throws -> CheckInDetail
    
    func openSettings() {
        _openSettings()
    }
    
    func requestCameraAccess() {
        _requestCameraAccess()
    }
    
    func createCaptureSession(resultHandler: @escaping ([AVMetadataMachineReadableCodeObject]) -> Void) -> AVCaptureSession? {
        _createCaptureSession(resultHandler)
    }
    
    func process(_ payload: String) throws -> CheckInDetail {
        try _process(payload)
    }
}
