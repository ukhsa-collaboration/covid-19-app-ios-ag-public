//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
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
        Metrics.signpost(.selectedTakeTestLaterM2Journey)
        _goHomeTapped()
    }
    
    func bookATestTapped() {
        Metrics.signpost(.selectedTakeTestM2Journey)
        _bookATestTapped()
    }
    
    func closeTapped() {
        _goHomeTapped()
    }
}
