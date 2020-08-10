//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class BluetoothDisabledViewController: RecoverableErrorViewController {
    
    public init() {
        super.init(error: BluetoothErrorDetail())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class BluetoothErrorDetail: ErrorDetail {
    
    let title = localize(.bluetooth_disabled_title)
    
    var action: (title: String, act: () -> Void)?
    
    private lazy var descriptionLabel1: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.bluetooth_disabled_description_1)
        return label
    }()
    
    private lazy var descriptionLabel2: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.bluetooth_disabled_description_2)
        return label
    }()
    
    private lazy var descriptionLabel3: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.bluetooth_disabled_description_3)
        return label
    }()
    
    private lazy var descriptionLabel4: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.bluetooth_disabled_description_4)
        return label
    }()
    
    var content: [UIView] {
        [descriptionLabel1, descriptionLabel2, descriptionLabel3, descriptionLabel4]
    }
}
