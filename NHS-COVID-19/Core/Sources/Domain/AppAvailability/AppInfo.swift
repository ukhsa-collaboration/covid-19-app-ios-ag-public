//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct AppInfo {
    var bundleId: String
    var version: Version
    
}

extension AppInfo {
    
    public init(bundleId: String, version: String) {
        self.bundleId = bundleId
        self.version = try! Version(version)
    }
    
    public init(for bundle: Bundle) {
        guard
            let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let version = try? Version(versionString) else {
            fatalError("Expected a semantic version number")
        }
        
        guard let bundleId = bundle.bundleIdentifier else {
            fatalError("Expected bundle id")
        }
        
        self.init(
            bundleId: bundleId,
            version: version
        )
    }
    
}
