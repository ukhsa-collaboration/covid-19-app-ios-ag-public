//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Foundation

public protocol CameraManaging {
    typealias AuthorizationStatus = AVAuthorizationStatus
    
    var instanceAuthorizationStatus: AuthorizationStatus { get }
    
    func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void)
    
    func createCaptureSession(handler: CaptureSessionOutputHandler) -> CaptureSession?
    
}

public class CameraManager: CameraManaging {
    
    public init() {}
    
    public var instanceAuthorizationStatus: AuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    public func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            handler(self.instanceAuthorizationStatus)
        }
    }
    
    public func createCaptureSession(handler: CaptureSessionOutputHandler) -> CaptureSession? {
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return nil
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            guard captureMetadataOutput.availableMetadataObjectTypes.contains(.qr) else {
                return nil
            }
            
            let delegate = CaptureMetadataOutputObjectsDelegate(handler: handler)
            captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
            
            let sessionContainer = CaptureSession(session: captureSession)
            sessionContainer.saveDelegate(delegate)
            return sessionContainer
        } catch {
            return nil
        }
    }
}

class CaptureMetadataOutputObjectsDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let handler: CaptureSessionOutputHandler
    
    init(handler: CaptureSessionOutputHandler) {
        self.handler = handler
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let qrCodes = metadataObjects.compactMap { object -> AVMetadataMachineReadableCodeObject? in
            guard let code = object as? AVMetadataMachineReadableCodeObject, code.type == .qr else {
                return nil
            }
            
            return code
        }
        
        qrCodes.first.map { qrCode in
            if let payload = qrCode.stringValue {
                handler.handleOutput(payload)
            }
        }
    }
}

public struct CaptureSessionOutputHandler {
    public var handleOutput: (String) -> Void
}

public class CaptureSession {
    var session: AVCaptureSession
    private var delegate: CaptureMetadataOutputObjectsDelegate?
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    func saveDelegate(_ delegate: CaptureMetadataOutputObjectsDelegate) {
        self.delegate = delegate
    }
}
