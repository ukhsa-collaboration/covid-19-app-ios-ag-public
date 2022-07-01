//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Localization
import UIKit

class ScanView: UIView {

    static let backgroundAlpha: CGFloat = 0.8
    static let scanWindowWidthRatio: CGFloat = 0.85
    static let scanWindowCornerRadius: CGFloat = 16.0

    private var scanWindowBound: CGRect {
        CGRect(x: scanWindowX, y: scanWindowY, width: scanWindowWidth, height: scanWindowHeight)
    }

    private var helpHandler: () -> Void

    private var scanWindowWidth: CGFloat = 0
    private var scanWindowHeight: CGFloat = 0
    private var scanWindowX: CGFloat = 0
    private var scanWindowY: CGFloat = 0

    private var cancellable: AnyCancellable?

    private var cameraState: AnyPublisher<QRScanner.State, Never>
    private var announceable: Bool = false

    private lazy var titleLabel: UIView = {
        let titleLabel = BaseLabel()
        titleLabel.text = localize(.checkin_camera_qrcode_scanner_title)
        titleLabel.styleAsPageHeader()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(.surface).resolvedColor(with: .init(userInterfaceStyle: .light))
        return titleLabel
    }()

    private lazy var statusLabel: UILabel = {
        let statusLabel = BaseLabel()
        statusLabel.text = localize(.checkin_camera_qrcode_scanner_status_label)
        statusLabel.styleAsTertiaryTitle()
        statusLabel.textAlignment = .center
        statusLabel.textColor = UIColor(.surface).resolvedColor(with: .init(userInterfaceStyle: .light))
        return statusLabel
    }()

    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = BaseLabel()
        descriptionLabel.text = localize(.checkin_camera_qrcode_scanner_description_label)
        descriptionLabel.styleAsBody()
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor(.surface).resolvedColor(with: .init(userInterfaceStyle: .light))
        return descriptionLabel
    }()

    private lazy var helpButtonContainer: UIView = {
        let sv = UIStackView(arrangedSubviews: [UIView(), helpButton, UIView()])
        sv.distribution = .equalSpacing
        return sv
    }()

    private lazy var helpButton: UIView = {
        let helpButton = UIButton()
        helpButton.layer.cornerRadius = .buttonCornerRadius
        helpButton.layer.borderWidth = 1
        helpButton.layer.borderColor = UIColor(.accessibleButtonOutline).cgColor
        helpButton.backgroundColor = .clear

        helpButton.contentEdgeInsets = UIEdgeInsets(
            top: .halfSpacing,
            left: .standardSpacing,
            bottom: .halfSpacing,
            right: .standardSpacing
        )

        let helpButtonTitle = localize(.checkin_camera_qrcode_scanner_help_button_title)
        helpButton.styleAsPlain(with: UIColor(.surface))
        helpButton.setTitle(helpButtonTitle, for: .normal)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        return helpButton
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            statusLabel,
            descriptionLabel,
            helpButtonContainer,
        ])
        stackView.spacing = .standardSpacing
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: .doubleSpacing,
            left: .standardSpacing,
            bottom: .standardSpacing,
            right: .standardSpacing
        )
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        return scrollView
    }()

    init(frame: CGRect, cameraState: AnyPublisher<QRScanner.State, Never>, helpHandler: @escaping () -> Void) {
        self.cameraState = cameraState
        self.helpHandler = helpHandler

        super.init(frame: frame)

        contentMode = .redraw
    }

    private func calculateScanWindow() {
        if isPortrait {
            scanWindowWidth = Self.scanWindowWidthRatio * frame.size.width
            scanWindowHeight = scanWindowWidth
            scanWindowX = 0.5 * (1 - Self.scanWindowWidthRatio) * frame.size.width
            scanWindowY = 100
        } else {
            let scanAreaWidth = frame.size.width / 2
            scanWindowHeight = Self.scanWindowWidthRatio * frame.size.height
            scanWindowWidth = scanWindowHeight
            scanWindowX = 0.5 * (scanAreaWidth - scanWindowWidth)
            scanWindowY = 0.5 * (1 - Self.scanWindowWidthRatio) * frame.size.height
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        calculateScanWindow()
        drawScanWindow(rect)
        #warning("we shouldn't be doing ui setup and config in the draw() method, layoutSubviews() is more appropriate")
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
        scrollView.removeFromSuperview()
        addAutolayoutSubview(scrollView)

        if isPortrait {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: scanWindowY + scanWindowHeight - .standardSpacing),
                scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                stackView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2 * scanWindowX + scanWindowWidth),
                scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            ])
        }
    }

    private func setupBindings() {
        guard cancellable == nil else {
            return
        }
        cancellable = cameraState.sink { [weak self] state in
            self?.announceable = state == .running
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
                self?.cameraActiveAnnouncement()
            case .stopped:
                self?.statusLabel.text = localize(.qrcoder_scanner_status_stopped)
            }
        }
    }

    @objc private func helpTapped() {
        helpHandler()
    }

    func cameraActiveAnnouncement() {
        #warning("Try and figure out how to defer an announcement until after the system has described the first UI element, usually the Close button")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard self?.announceable == true else {
                return
            }
            UIAccessibility.post(notification: .announcement, argument: NSAttributedString(string: localize(.camera_active_accessibility_announcement), attributes: [.accessibilitySpeechLanguage: currentLocaleIdentifier()]))
        }
    }
}

private extension CGFloat {

    static let standardMargin: CGFloat = 64

}
