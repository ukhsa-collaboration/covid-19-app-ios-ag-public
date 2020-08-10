//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import Common
import Domain
import Integration
import Interface
import SwiftUI
import UIKit

public class QRCodeScannerEmbeddedScenario: Scenario {
    
    public static let name = "QR Code Scanner (Embedded)"
    
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        QRCodeScannerEmbeddedAppController()
    }
}

private struct QRCodeScannerEmbeddedAppController: AppController {
    let rootViewController: UIViewController = UIHostingController(rootView: HomeView())
}

public class QRCodeScannerFullscreenScenario: Scenario {
    
    public static let name = "QR Code Scanner (Fullscreen)"
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        QRCodeScannerFullscreenAppController()
    }
}

private struct QRCodeScannerFullscreenAppController: AppController {
    let rootViewController: UIViewController = QRCodeScannerViewController()
}

private struct HomeView: View {
    
    var body: some View {
        TabView {
            StatusView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("About me")
                }
            
            QRCodeView()
                .tabItem {
                    Image(systemName: "qrcode")
                    Text("Check In")
                }
        }
    }
}

private struct StatusView: View {
    var body: some View {
        ScrollView {
            Image("homescreen")
                .aspectRatio(contentMode: .fill)
        }
    }
}

private struct QRCodeView: View {
    var body: some View {
        QRCodeScannerView()
        
    }
}

class QRCodeScannerViewController: UIViewController {
    
    enum State: Equatable {
        case starting
        case failed(reason: String)
        case running
        case scanning
        case processing
        case stopped
    }
    
    @Published
    var state = QRCodeScannerViewController.State.starting
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var scanView: ScanView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLiveCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopLiveCamera()
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            state = .failed(reason: "failed to intialize a camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
            
        } catch {
            state = .failed(reason: error.localizedDescription)
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        scanView = ScanView(frame: view.bounds, cameraState: $state.eraseToAnyPublisher(), helpHandler: { [weak self] in
            self?.showHelp()
        })
        
        view.addFillingSubview(scanView)
    }
    
    private func startLiveCamera() {
        captureSession.startRunning()
        state = .running
    }
    
    private func stopLiveCamera() {
        captureSession.stopRunning()
        state = .stopped
    }
    
    private func process(_ payload: String) {
        
        guard state == .scanning else {
            return
        }
        
        state = .processing
        captureSession.stopRunning()
        
        let alertPrompt = UIAlertController(title: nil, message: "Payload: \(payload)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Check In", style: .default, handler: { _ in
            self.checkIn(with: payload)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.startLiveCamera()
        })
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
    private func checkIn(with payload: String) {
        let viewController = UIHostingController(
            rootView: CheckInView(
                dismiss: {
                    self.dismiss(animated: true, completion: nil)
                },
                payload: payload
            )
        )
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
    
    private func showHelp() {
        let viewController = UIHostingController(
            rootView: HelpView(
                dismiss: {
                    self.dismiss(animated: true, completion: nil)
                }
            )
        )
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        let qrCodes = metadataObjects.compactMap { object -> AVMetadataMachineReadableCodeObject? in
            guard let code = object as? AVMetadataMachineReadableCodeObject, code.type == .qr else {
                return nil
            }
            
            return code
        }
        
        qrCodes.first.map { qrCode in
            
            guard let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: qrCode) else {
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

private struct QRCodeScannerView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let viewController = QRCodeScannerViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: QRCodeScannerView
        
        init(_ viewController: QRCodeScannerView) {
            parent = viewController
        }
    }
}

private class ScanView: UIView {
    
    static let backgroundAlpha: CGFloat = 0.9
    static let scanWindowWidthRadio: CGFloat = 0.6
    static let scanWindowCornerRadius: CGFloat = 16.0
    
    lazy var scanWindowBound: CGRect = {
        CGRect(x: scanWindowX, y: scanWindowY, width: scanWindowWidth, height: scanWindowHeight)
    }()
    
    var helpHandler: () -> Void
    
    private var statusLabel: UILabel!
    private var scanWindowWidth: CGFloat
    private var scanWindowHeight: CGFloat
    private var scanWindowX: CGFloat
    private var scanWindowY: CGFloat
    
    private var cancellable: AnyCancellable?
    
    var cameraState: AnyPublisher<QRCodeScannerViewController.State, Never>
    
    init(frame: CGRect, cameraState: AnyPublisher<QRCodeScannerViewController.State, Never>, helpHandler: @escaping () -> Void) {
        
        scanWindowWidth = Self.scanWindowWidthRadio * frame.size.width
        scanWindowHeight = scanWindowWidth
        scanWindowX = 0.5 * (1 - Self.scanWindowWidthRadio) * frame.size.width
        scanWindowY = 0.5 * (frame.size.height - scanWindowWidth)
        
        self.cameraState = cameraState
        self.helpHandler = helpHandler
        
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        drawScanWindow(rect)
        setupUI()
        setupBindings()
    }
    
    private func drawScanWindow(_ rect: CGRect) {
        UIColor.black.withAlphaComponent(Self.backgroundAlpha).setFill()
        UIRectFill(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.destinationOut)
        
        let bezierPath = UIBezierPath(
            roundedRect: scanWindowBound,
            cornerRadius: Self.scanWindowCornerRadius
        )
        
        bezierPath.fill()
    }
    
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Scan QR code to check-in"
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        addAutolayoutSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 64),
        ])
        statusLabel = UILabel()
        statusLabel.text = "Point to a QRCode"
        statusLabel.styleAsBody()
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        
        addAutolayoutSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            statusLabel.topAnchor.constraint(equalTo: topAnchor, constant: scanWindowY + scanWindowHeight + 16),
        ])
        
        let helpButton = UIButton()
        helpButton.setTitle("\u{24D8} Why do I need to scan?", for: .normal)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        
        addAutolayoutSubview(helpButton)
        
        NSLayoutConstraint.activate([
            helpButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            helpButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -64.0),
        ])
    }
    
    private func setupBindings() {
        cancellable = cameraState.sink { [weak self] state in
            switch state {
            case .starting:
                self?.statusLabel.text = "Starting ..."
            case .scanning:
                self?.statusLabel.text = "Scanning ..."
            case .processing:
                self?.statusLabel.text = "Processing ..."
            case .failed(let reason):
                self?.statusLabel.text = "Failed: \(reason)"
            case .running:
                self?.statusLabel.text = "Point to a QRCode"
            case .stopped:
                self?.statusLabel.text = "Stopped!"
            }
        }
    }
    
    @objc private func helpTapped() {
        helpHandler()
    }
}

private struct HelpView: View {
    
    var dismiss: () -> Void
    
    var body: some View {
        ZStack {
            Button(
                action: { self.dismiss() }
            ) { Image(systemName: "xmark") }
                .position(x: 16, y: 16)
            
            VStack {
                Text("Checking in help us prevent Covid-19 spreading")
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

private struct CheckInView: View {
    var dismiss: () -> Void
    
    var payload: String
    
    @State private var size = UIScreen.main.bounds.size.width * 1.5
    @State private var opacityValue: Double = 0.0
    
    var body: some View {
        ZStack {
            Button(
                action: { self.dismiss() }
            ) { Image(systemName: "xmark") }
                .position(x: 16, y: 16)
            
            VStack {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .foregroundColor(Color(.nhsBlue))
                    .opacity(self.opacityValue)
                    .animation(.easeIn)
                    .frame(width: self.size, height: self.size)
                
                Text("Checked in")
                    .font(.title).bold()
                
                Text("Thank you for scanning. You are now checked in")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal)
                
                Text(payload)
                    .padding()
            }
        }
        .onAppear {
            self.size = 100
            self.opacityValue = 1
        }
    }
}
