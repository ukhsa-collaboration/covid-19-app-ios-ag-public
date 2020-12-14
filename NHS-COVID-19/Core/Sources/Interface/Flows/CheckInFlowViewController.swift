//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public struct CheckInDetail {
    public var venueName: String
    public var removeCurrentCheckIn: () -> Void
    
    public init(venueName: String, removeCurrentCheckIn: @escaping () -> Void) {
        self.venueName = venueName
        self.removeCurrentCheckIn = removeCurrentCheckIn
    }
}

public protocol CheckInFlowViewControllerInteracting: CameraAccessDeniedViewControllerInteracting {
    func process(_ payload: String) throws -> CheckInDetail
}

public enum CameraPermissionState {
    case notDetermined
    case authorized
    case denied
}

public class CheckInFlowViewController: UINavigationController {
    
    public typealias Interacting = CheckInFlowViewControllerInteracting
    
    private enum State: Equatable {
        case start
        case permissionDenied
        case cameraFailure
        case scanningFailure
        case confirm
    }
    
    private var cameraPermissionState: AnyPublisher<CameraPermissionState, Never>
    private let scanner: QRScanner
    private let interactor: Interacting
    
    @Published
    private var state = State.start
    
    private var cancellables = [AnyCancellable]()
    
    private var checkInDetail: CheckInDetail!
    private var currentDateProvider: DateProviding
    private let goHomeCompletion: () -> Void
    
    public init(cameraPermissionState: AnyPublisher<CameraPermissionState, Never>,
                scanner: QRScanner,
                interactor: Interacting,
                currentDateProvider: DateProviding,
                goHomeCompletion: @escaping () -> Void) {
        self.cameraPermissionState = cameraPermissionState
        self.scanner = scanner
        self.interactor = interactor
        self.currentDateProvider = currentDateProvider
        self.goHomeCompletion = goHomeCompletion
        super.init(nibName: nil, bundle: nil)
        
        cameraPermissionState
            .sink { [weak self] cameraAuthorizationState in
                switch cameraAuthorizationState {
                case .notDetermined, .authorized:
                    return
                case .denied:
                    self?.state = .permissionDenied
                }
            }
            .store(in: &cancellables)
        
        scanner.state
            .sink { [weak self] scannerState in
                if scannerState == .failed {
                    self?.state = .cameraFailure
                }
            }
            .store(in: &cancellables)
        
        $state
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
        
        setupNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(for state: State) {
        if viewControllers.isEmpty {
            viewControllers = [
                rootViewController(for: state),
            ]
        } else {
            viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
            pushViewController(rootViewController(for: state), animated: true)
        }
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            let vc = QRCodeScannerViewController(
                interactor: self,
                cameraPermissionState: cameraPermissionState,
                scanner: scanner,
                completion: { [weak self] payload in
                    guard let self = self, self.state == .start else { return }
                    do {
                        self.checkInDetail = try self.interactor.process(payload)
                        self.state = .confirm
                    } catch {
                        self.state = .scanningFailure
                    }
                }
            )
            #warning("Find a better way of doing this")
            DispatchQueue.main.async {
                self.setOverrideTraitCollection(UITraitCollection(userInterfaceStyle: .light), forChild: vc)
            }
            return vc
        case .permissionDenied:
            return CameraAccessDeniedViewController(interactor: interactor)
        case .cameraFailure:
            return CameraFailureViewController(interactor: self)
        case .scanningFailure:
            return ScanningFailureViewController(interactor: self)
        case .confirm:
            return CheckInConfirmationViewController(
                interactor: self,
                checkInDetail: checkInDetail,
                date: currentDateProvider.currentDate
            )
        }
    }
    
    private func setupNavigationBar() {
        navigationBar.tintColor = UIColor(.nhsBlue)
        navigationBar.barTintColor = UIColor(.background)
    }
}

extension CheckInFlowViewController: CameraFailureViewController.Interacting, ScanningFailureViewController.Interacting, CheckInConfirmationViewController.Interacting, QRCodeScannerViewController.Interacting, VenueCheckInInformationViewController.Interacting {
    
    public func goHome() {
        dismiss(animated: true, completion: nil)
    }
    
    public func goHomeAfterCheckIn() {
        dismiss(animated: true, completion: goHomeCompletion)
    }
    
    public func wrongCheckIn() {
        dismiss(animated: true, completion: nil)
    }
    
    public func didTapVenueCheckinMoreInfoButton() {
        showHelp()
    }
    
    public func showHelp() {
        let viewController = UINavigationController(rootViewController: VenueCheckInInformationViewController(interactor: self))
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true, completion: nil)
    }
    
    public func didTapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}
