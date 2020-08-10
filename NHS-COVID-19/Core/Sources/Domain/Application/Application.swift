//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public protocol Application {
    typealias OpenExternalURLOptionsKey = UIApplication.OpenExternalURLOptionsKey
    
    var instanceOpenSettingsURLString: String { get }
    func open(_ url: URL, options: [OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
    
}

extension UIApplication: Application {
    public var instanceOpenSettingsURLString: String {
        Self.openSettingsURLString
    }
}

extension Application {
    
    func open(_ url: URL, options: [OpenExternalURLOptionsKey: Any] = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
        open(url, options: options, completionHandler: completion)
    }
    
    func openSettings() {
        if let url = URL(string: instanceOpenSettingsURLString) {
            open(url)
        }
    }
    
}
