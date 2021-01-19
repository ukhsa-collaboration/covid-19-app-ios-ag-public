//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public class BluetoothDisabledViewController: RecoverableErrorViewController {
    
    public init(country: Country) {
        super.init(error: BluetoothErrorDetail(country: country))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class BluetoothErrorDetail: ErrorDetail {
    let country: Country
    
    let title = localize(.bluetooth_disabled_title)
    
    var logoStrapLineStyle: LogoStrapline.Style { .home(country) }
    
    var action: (title: String, act: () -> Void)?
    
    var content: [UIView] {
        localizeAndSplit(.bluetooth_disabled_description)
            .map { text in
                BaseLabel().set(text: String(text)).styleAsBody()
            }
    }
    
    init(country: Country) {
        self.country = country
    }
}
