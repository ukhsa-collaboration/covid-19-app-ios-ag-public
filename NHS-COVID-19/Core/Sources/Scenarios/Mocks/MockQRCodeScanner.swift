//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Domain

public struct MockQRCodeScanner: QRCodeScanning {
    
    public init() {}
    
    public func createCaptureSession(resultHandler: @escaping ([AVMetadataMachineReadableCodeObject]) -> Void) -> AVCaptureSession? {
        return AVCaptureSession()
    }
}
