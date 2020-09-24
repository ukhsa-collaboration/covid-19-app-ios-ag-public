//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import UIKit

public protocol QRCodeScanning {
    func getState() -> AnyPublisher<QRCodeScannerState, Never>
    func startScanner(targetView: UIView, scanViewBounds: CGRect, resultHandler: @escaping (String) -> Void)
    func stopScanner()
    func changeOrientation(viewBounds: CGRect, scanViewBounds: CGRect, orientation: UIInterfaceOrientation)
    func reset()
}

public enum QRCodeScannerState: Equatable {
    case starting
    case failed
    case requestingPermission
    case running
    case scanning
    case processing
    case stopped
}

public class QRCodeScanner: QRCodeScanning {
    @Published
    public var state: QRCodeScannerState = QRCodeScannerState.starting
    
    public let cameraStateController: CameraStateController
    private let cameraManager: CameraManaging
    
    private var cancellable: AnyCancellable?
    private var isCameraSetup: Bool = false
    
    private var targetView: UIView?
    private var scanViewBounds: CGRect?
    private var resultHandler: ((String) -> Void)?
    private var captureSession: CaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureSessionOutputHandler: CaptureSessionOutputHandler?
    
    init(cameraManager: CameraManaging, cameraStateController: CameraStateController) {
        self.cameraManager = cameraManager
        self.cameraStateController = cameraStateController
    }
    
    public func getState() -> AnyPublisher<QRCodeScannerState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    public func startScanner(targetView: UIView, scanViewBounds: CGRect, resultHandler: @escaping (String) -> Void) {
        guard cancellable == nil else { return }
        
        self.targetView = targetView
        self.resultHandler = resultHandler
        self.scanViewBounds = scanViewBounds
        
        cancellable = cameraStateController.$authorizationState
            .receive(on: RunLoop.main)
            .sink { cameraState in
                if cameraState == .authorized {
                    self.setupCamera()
                } else if cameraState == .notDetermined {
                    self.state = .requestingPermission
                    self.cameraStateController.requestAccess()
                }
            }
        
        if isCameraSetup {
            state = .running
        }
    }
    
    private func setupCamera() {
        guard !isCameraSetup else { return }
        
        guard let resultHandler = resultHandler,
            let session = createCaptureSession(resultHandler: resultHandler) else {
            state = .failed
            return
        }
        captureSession = session
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session.session)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        if let targetView = targetView {
            videoPreviewLayer?.frame = targetView.layer.bounds
            videoPreviewLayer.map { targetView.layer.insertSublayer($0, at: 0) }
        }
        
        isCameraSetup = true
        captureSession?.session.startRunning()
        state = .running
    }
    
    public func stopScanner() {
        if isCameraSetup {
            state = .stopped
            captureSession?.session.stopRunning()
        }
    }
    
    public func changeOrientation(viewBounds: CGRect, scanViewBounds: CGRect, orientation: UIInterfaceOrientation) {
        guard let videoPreviewLayer = self.videoPreviewLayer,
            let connection = videoPreviewLayer.connection else {
            return
        }
        
        self.scanViewBounds = scanViewBounds
        
        if connection.isVideoOrientationSupported, let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
            videoPreviewLayer.frame = viewBounds
            connection.videoOrientation = videoOrientation
        }
    }
    
    private func createCaptureSession(resultHandler: @escaping (String) -> Void) -> CaptureSession? {
        
        let handler = CaptureSessionOutputHandler(
            getScanViewBounds: {
                self.scanViewBounds
            },
            getVideoPreviewLayer: {
                self.videoPreviewLayer
            },
            handleOutput: { payload in
                self.state = .scanning
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard self.state == .scanning else { return }
                    self.state = .processing
                    resultHandler(payload)
                }
                
            }
        )
        
        captureSessionOutputHandler = handler
        return cameraManager.createCaptureSession(handler: handler)
    }
    
    public func reset() {
        state = .starting
        cancellable = nil
        isCameraSetup = false
        targetView = nil
        scanViewBounds = nil
        resultHandler = nil
        captureSession = nil
        videoPreviewLayer = nil
        captureSessionOutputHandler = nil
    }
}
