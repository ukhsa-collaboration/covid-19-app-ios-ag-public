//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct App {
    static let compilationRequirements: [CompilationRequirement] = [
        MinimumOSCompilationRequirement.macOS10_15_4,
        MinimumXcodeCompilationRequirement.xcode11,
        MinimumPlatformCompilationRequirement.ios13,
        CompilerCompilationRequirement.clang1,
        PlatformCompilationRequirement.iOSDevice,
    ]
    
    static let knownAssets: [Asset] = [
        .strings("Localizable"),
        .stringsdict("Localizable"),
        .strings("InfoPlist"),
        .bundle("Settings"),
        .bundle("Core_Domain"),
        .bundle("Core_Localization"),
        .content(name: "PostalDistricts", suffix: "json"),
    ]
}
