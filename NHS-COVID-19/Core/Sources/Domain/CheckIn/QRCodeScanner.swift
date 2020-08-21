//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import UIKit

public protocol QRCodeScanning {
    func createCaptureSession(resultHandler: @escaping ([AVMetadataMachineReadableCodeObject]) -> Void) -> AVCaptureSession?
}

public class QRCodeScanner: QRCodeScanning {
    var cameraManager: CameraManaging
    
    init(cameraManager: CameraManaging) {
        self.cameraManager = cameraManager
    }
    
    public func createCaptureSession(resultHandler: @escaping ([AVMetadataMachineReadableCodeObject]) -> Void) -> AVCaptureSession? {
        let handler = CaptureSessionOutputHandler { metadataObjects in
            let qrCodes = metadataObjects.compactMap { object -> AVMetadataMachineReadableCodeObject? in
                guard let code = object as? AVMetadataMachineReadableCodeObject, code.type == .qr else {
                    return nil
                }
                
                return code
            }
            
            resultHandler(qrCodes)
        }
        return cameraManager.createCaptureSession(handler: handler)
    }
}
