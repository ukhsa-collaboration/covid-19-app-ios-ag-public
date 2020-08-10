//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import Common
import Localization
import UIKit

public protocol QRCodeScannerViewControllerInteracting {
    func showHelp()
    func didFailedToInitializeCamera()
}

public class QRCodeScannerViewController: UIViewController {
    
    public typealias Interacting = QRCodeScannerViewControllerInteracting
    
    enum State: Equatable {
        case starting
        case failed
        case requestingPermission
        case running
        case scanning
        case processing
        case stopped
    }
    
    @Published
    private var state = QRCodeScannerViewController.State.starting {
        didSet {
            switch state {
            case .running:
                captureSession.startRunning()
            case .processing, .stopped:
                captureSession.stopRunning()
            case .failed:
                interactor.didFailedToInitializeCamera()
            default:
                break
            }
        }
    }
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var scanView: ScanView!
    
    private var cameraPermissionState: AnyPublisher<CameraPermissionState, Never>
    private var requestCameraAccess: () -> Void
    private var cancellable: AnyCancellable?
    
    private var isCameraSetup: Bool = false
    
    private var completion: (String) -> Void
    
    private var interactor: Interacting
    
    public init(
        interactor: Interacting,
        cameraPermissionState: AnyPublisher<CameraPermissionState, Never>,
        requestCameraAccess: @escaping () -> Void,
        completion: @escaping (String) -> Void
    ) {
        self.interactor = interactor
        self.cameraPermissionState = cameraPermissionState
        self.requestCameraAccess = requestCameraAccess
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
        if isCameraSetup {
            state = .running
        }
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isCameraSetup {
            state = .stopped
        }
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let videoPreviewLayer = self.videoPreviewLayer,
            let connection = videoPreviewLayer.connection else {
            return
        }
        
        let orientation = UIDevice.current.orientation
        
        if connection.isVideoOrientationSupported, let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
            videoPreviewLayer.frame = view.bounds
            connection.videoOrientation = videoOrientation
        }
    }
    
    private func setupBindings() {
        guard cancellable == nil else { return }
        
        cancellable = cameraPermissionState
            .receive(on: RunLoop.main)
            .sink { cameraState in
                if cameraState == .authorized {
                    self.setupCamera()
                } else if cameraState == .notDetermined {
                    self.authorize()
                }
            }
    }
    
    private func setupUI() {
        scanView = ScanView(
            frame: view.bounds,
            cameraState: $state.eraseToAnyPublisher(),
            helpHandler: { [weak self] in
                self?.showHelp()
            }
        )
        
        view.addFillingSubview(scanView)
        
        let closeButton = UIButton()
        closeButton.setTitleColor(UIColor(.surface), for: .normal)
        closeButton.setTitle(localize(.checkin_qrcode_scanner_close_button_title), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.showsLargeContentViewer = true
        closeButton.largeContentTitle = localize(.checkin_qrcode_scanner_close_button_title)
        closeButton.addInteraction(UILargeContentViewerInteraction())
        view.addAutolayoutSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .standardSpacing),
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),
        ])
    }
    
    private func setupCamera() {
        guard !isCameraSetup else { return }
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            state = .failed
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            guard captureMetadataOutput.availableMetadataObjectTypes.contains(.qr) else {
                state = .failed
                return
            }
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
        } catch {
            state = .failed
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        videoPreviewLayer.map { view.layer.insertSublayer($0, at: 0) }
        
        isCameraSetup = true
        
        state = .running
    }
    
    private func process(_ payload: String) {
        guard state == .scanning else {
            return
        }
        
        state = .processing
        
        completion(payload)
    }
    
    private func authorize() {
        state = .requestingPermission
        requestCameraAccess()
    }
    
    private func showHelp() {
        interactor.showHelp()
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let qrCodes = metadataObjects.compactMap { object -> AVMetadataMachineReadableCodeObject? in
            guard let code = object as? AVMetadataMachineReadableCodeObject, code.type == .qr else {
                return nil
            }
            
            return code
        }
        
        qrCodes.first.map { qrCode in
            guard let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: qrCode) else {
                return
            }
            
            guard self.scanView.scanWindowBound.contains(barCodeObject.bounds) else {
                return
            }
            
            if let payload = qrCode.stringValue {
                self.state = .scanning
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.process(payload)
                }
            }
        }
    }
}
