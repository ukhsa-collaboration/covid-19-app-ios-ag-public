//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface

struct SettingsViewControllerInteractor: SettingsViewController.Interacting {
    var _didTapLanguage: () -> Void
    
    func didTapLanguage() {
        _didTapLanguage()
    }
}
