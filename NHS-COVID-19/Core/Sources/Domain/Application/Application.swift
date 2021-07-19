//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

public protocol Application {
    typealias OpenExternalURLOptionsKey = UIApplication.OpenExternalURLOptionsKey
    
    var instanceOpenSettingsURLString: String { get }
    var instanceOpenAppStoreURLString: String { get }
    func open(_ url: URL, options: [OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
    
}

extension UIApplication: Application {
    public var instanceOpenSettingsURLString: String {
        Self.openSettingsURLString
    }
    
    public var instanceOpenAppStoreURLString: String {
        "https://apps.apple.com/gb/app/nhs-covid-19/id1520427663"
    }
}

extension Application {
    
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
    
    func openSettings() {
        if let url = URL(string: instanceOpenSettingsURLString) {
            open(url)
        }
    }
    
    func openAppStore() {
        if let url = URL(string: instanceOpenAppStoreURLString) {
            open(url)
        }
    }
}
