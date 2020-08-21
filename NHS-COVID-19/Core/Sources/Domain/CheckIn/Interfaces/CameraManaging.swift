//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Foundation

public protocol CameraManaging {
    typealias AuthorizationStatus = AVAuthorizationStatus
    
    var instanceAuthorizationStatus: AuthorizationStatus { get }
    
    func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void)
    
    func createCaptureSession(handler: CaptureSessionOutputHandler) -> AVCaptureSession?
    
}

public class CameraManager: CameraManaging {
    #warning("Find a better way to save this delegate from being deleted too early")
    private var delegate: CaptureMetadataOutputObjectsDelegate?
    
    public init() {}
    
    public var instanceAuthorizationStatus: AuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    public func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            handler(self.instanceAuthorizationStatus)
        }
    }
    
    public func createCaptureSession(handler: CaptureSessionOutputHandler) -> AVCaptureSession? {
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
            
            delegate = CaptureMetadataOutputObjectsDelegate(handler: handler)
            captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
        } catch {
            return nil
        }
        return captureSession
    }
}

class CaptureMetadataOutputObjectsDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let handler: CaptureSessionOutputHandler
    
    init(handler: CaptureSessionOutputHandler) {
        self.handler = handler
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        handler.handleOutput(metadataObjects)
    }
}

public struct CaptureSessionOutputHandler {
    var handleOutput: ([AVMetadataObject]) -> Void
}
