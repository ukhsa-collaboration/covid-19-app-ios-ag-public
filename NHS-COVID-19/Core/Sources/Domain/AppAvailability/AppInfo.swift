//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct AppInfo {
    public var bundleId: String
    public var version: Version
    public var buildNumber: String
    
}

extension AppInfo {
    
    public init(bundleId: String, version: String, buildNumber: String) {
        self.bundleId = bundleId
        self.version = try! Version(version)
        self.buildNumber = buildNumber
    }
    
    public init(for bundle: Bundle) {
        guard
            let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let version = try? Version(versionString) else {
            fatalError("Expected a semantic version number")
        }
        
        guard let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("Expected a build number")
        }
        
        guard let bundleId = bundle.bundleIdentifier else {
            fatalError("Expected bundle id")
        }
        
        self.init(
            bundleId: bundleId,
            version: version,
            buildNumber: buildNumber
        )
    }
    
}
