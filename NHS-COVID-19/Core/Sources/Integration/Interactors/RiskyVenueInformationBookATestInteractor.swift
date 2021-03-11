//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import UIKit

struct RiskyVenueInformationBookATestInteractor: RiskyVenueInformationBookATestViewController.Interacting {
    private var _bookATestTapped: () -> Void
    private var _goHomeTapped: () -> Void
    
    init(bookATestTapped: @escaping () -> Void, goHomeTapped: @escaping () -> Void) {
        _goHomeTapped = goHomeTapped
        _bookATestTapped = bookATestTapped
    }
    
    func bookATestLaterTapped() {
        _goHomeTapped()
    }
    
    func bookATestTapped() {
        _bookATestTapped()
    }
    
    func closeTapped() {
        _goHomeTapped()
    }
}
