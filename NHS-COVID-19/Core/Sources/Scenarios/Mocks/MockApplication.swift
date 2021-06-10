//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation

public class MockApplication: Application {
    
    public var instanceOpenSettingsURLString = "settings://\(UUID().uuidString)"
    public var instanceOpenAppStoreURLString = "https://apps.apple.com/gb/app/nhs-covid-19/id1520427663"

    public var openedURL: URL?
    
    public init() {}
    
    public func open(_ url: URL, options: [OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
        openedURL = url
    }
}
