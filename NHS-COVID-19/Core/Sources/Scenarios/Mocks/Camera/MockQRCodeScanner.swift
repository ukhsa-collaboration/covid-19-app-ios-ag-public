//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import UIKit

public class MockQRCodeScanner: QRCodeScanning {
    var showPermissionAlert = true
    var result = "RESULT"

    private var resultHandler: ((String) -> Void)?

    public var state: QRCodeScannerState = QRCodeScannerState.starting

    public init() {}

    public func getState() -> AnyPublisher<QRCodeScannerState, Never> {
        Just(state).eraseToAnyPublisher()
    }

    public func startScanner(targetView: UIView, resultHandler: @escaping (String) -> Void) {
        if showPermissionAlert {
            state = .requestingPermission
            showPermissionAlert = false
        } else {
            state = .running
        }
    }

    public func stopScanner() {
        state = .stopped
    }

    public func changeOrientation(viewBounds: CGRect, orientation: UIInterfaceOrientation) {}

    public func reset() {}

    func scan() {
        resultHandler?(result)
    }
}
