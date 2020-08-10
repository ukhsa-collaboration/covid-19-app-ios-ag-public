//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import Localization
import UIKit

class ScanView: UIView {
    
    static let backgroundAlpha: CGFloat = 0.8
    static let scanWindowWidthRatio: CGFloat = 0.6
    static let scanWindowCornerRadius: CGFloat = 16.0
    
    lazy var scanWindowBound: CGRect = {
        CGRect(x: scanWindowX, y: scanWindowY, width: scanWindowWidth, height: scanWindowHeight)
    }()
    
    var helpHandler: () -> Void
    
    private var scanWindowWidth: CGFloat
    private var scanWindowHeight: CGFloat
    private var scanWindowX: CGFloat
    private var scanWindowY: CGFloat
    
    private var cancellable: AnyCancellable?
    
    var cameraState: AnyPublisher<QRCodeScannerViewController.State, Never>
    
    private lazy var titleLabel: UIView = {
        let titleLabel = UILabel()
        titleLabel.text = localize(.checkin_camera_qrcode_scanner_title)
        titleLabel.styleAsPageHeader()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(.surface).resolvedColor(with: .init(userInterfaceStyle: .light))
        return titleLabel
    }()
    
    private lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = localize(.checkin_camera_qrcode_scanner_status_label)
        statusLabel.styleAsBody()
        statusLabel.textAlignment = .center
        statusLabel.textColor = UIColor(.surface).resolvedColor(with: .init(userInterfaceStyle: .light))
        return statusLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = localize(.checkin_camera_qrcode_scanner_description_label)
        descriptionLabel.styleAsBody()
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor(.surface).resolvedColor(with: .init(userInterfaceStyle: .light))
        return descriptionLabel
    }()
    
    private lazy var helpButton: UIView = {
        let helpButton = UIButton()
        let helpButtonTitle = localize(.checkin_camera_qrcode_scanner_help_button_title)
        helpButton.styleAsPlain(with: UIColor(.surface))
        helpButton.setTitle(helpButtonTitle, for: .normal)
        helpButton.accessibilityLabel = localize(.checkin_camera_qrcode_scanner_help_button_accessibility_label)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        return helpButton
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            helpButton,
            statusLabel,
            descriptionLabel,
        ])
        stackView.spacing = .standardSpacing
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .standard
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        return scrollView
    }()
    
    init(frame: CGRect, cameraState: AnyPublisher<QRCodeScannerViewController.State, Never>, helpHandler: @escaping () -> Void) {
        
        scanWindowWidth = Self.scanWindowWidthRatio * frame.size.width
        scanWindowHeight = scanWindowWidth
        scanWindowX = 0.5 * (1 - Self.scanWindowWidthRatio) * frame.size.width
        scanWindowY = 100
        
        self.cameraState = cameraState
        self.helpHandler = helpHandler
        
        super.init(frame: frame)
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
        addAutolayoutSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: scanWindowY + scanWindowHeight + .standardSpacing),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    private func setupBindings() {
        cancellable = cameraState.sink { [weak self] state in
            switch state {
            case .starting:
                self?.backgroundColor = .black
                self?.statusLabel.text = localize(.qrcoder_scanner_status_starting)
            case .requestingPermission:
                self?.statusLabel.text = localize(.qrcoder_scanner_status_requesting_permission)
            case .scanning:
                self?.statusLabel.text = localize(.qrcoder_scanner_status_scanning)
            case .processing:
                self?.statusLabel.text = localize(.qrcoder_scanner_status_processing)
            case .failed:
                self?.statusLabel.text = ""
            case .running:
                self?.backgroundColor = .clear
                self?.statusLabel.text = localize(.qrcoder_scanner_status_running)
            case .stopped:
                self?.statusLabel.text = localize(.qrcoder_scanner_status_stopped)
            }
        }
    }
    
    @objc private func helpTapped() {
        helpHandler()
    }
}

private extension CGFloat {
    
    static let standardMargin: CGFloat = 64
    
}
