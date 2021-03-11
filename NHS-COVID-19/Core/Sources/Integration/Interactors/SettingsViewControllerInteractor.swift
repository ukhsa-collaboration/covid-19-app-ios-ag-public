//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface

struct SettingsViewControllerInteractor: SettingsViewController.Interacting {
    var _didTapLanguage: () -> Void
    var _didTapManageMyData: () -> Void
    
    func didTapLanguage() {
        _didTapLanguage()
    }
    
    func didTapManageMyData() {
        _didTapManageMyData()
    }
}
