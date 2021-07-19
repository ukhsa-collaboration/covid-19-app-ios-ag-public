//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol QRCodeScannerViewControllerInteracting {
    func showHelp()
}

public class QRScanner {
    public typealias StartScanning = (UIView, @escaping (String) -> Void) -> Void
    public typealias StopScanning = () -> Void
    public typealias LayoutFinished = (CGRect, UIInterfaceOrientation) -> Void
    
    public enum State: Equatable {
        case starting
        case failed
        case requestingPermission
        case running
        case scanning
        case processing
        case stopped
    }
    
    public var state: AnyPublisher<State, Never>
    
    private var _startScanning: StartScanning
    private var _stopScanning: StopScanning
    private var _layoutFinished: LayoutFinished
    
    public init(state: AnyPublisher<State, Never>,
                startScanning: @escaping StartScanning,
                stopScanning: @escaping StopScanning,
                layoutFinished: @escaping LayoutFinished) {
        self.state = state
        _startScanning = startScanning
        _stopScanning = stopScanning
        _layoutFinished = layoutFinished
    }
    
    func startScanning(targetView: UIView, resultHandler: @escaping (String) -> Void) {
        _startScanning(targetView, resultHandler)
    }
    
    func stopScanning() {
        _stopScanning()
    }
    
    func layoutFinished(viewBounds: CGRect, orientation: UIInterfaceOrientation) {
        _layoutFinished(viewBounds, orientation)
    }
}

public class QRCodeScannerViewController: UIViewController {
    
    public typealias Interacting = QRCodeScannerViewControllerInteracting
    
    private var scanner: QRScanner
    
    private var scanView: ScanView!
    
    private var cameraPermissionState: AnyPublisher<CameraPermissionState, Never>
    
    private var isCameraSetup: Bool = false
    
    private var completion: (String) -> Void
    
    private var interactor: Interacting
    
    private var orientationCancellable: AnyCancellable?
    
    public init(
        interactor: Interacting,
        cameraPermissionState: AnyPublisher<CameraPermissionState, Never>,
        scanner: QRScanner,
        completion: @escaping (String) -> Void
    ) {
        self.interactor = interactor
        self.cameraPermissionState = cameraPermissionState
        self.completion = completion
        self.scanner = scanner
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        orientationCancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification).sink { [weak self] _ in
            self?.layoutFinished()
        }
    }
    
    func layoutFinished() {
        scanner.layoutFinished(viewBounds: view.bounds, orientation: view.interfaceOrientation)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanner.startScanning(targetView: view, resultHandler: completion)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanner.stopScanning()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutFinished()
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    private func setupUI() {
        scanView = ScanView(
            frame: view.bounds,
            cameraState: scanner.state,
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
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .standardSpacing),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    private func showHelp() {
        interactor.showHelp()
    }
    
    func announceCameraIfRunning() {
        scanView.cameraActiveAnnouncement()
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
