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

    static let corePackageSourcesPathComponent = "NHS-COVID-19/Core/Sources"

    static let localizableStringsResourcePath = "Localization/Resources/en.lproj/Localizable.strings"

    static let localizableStringsDictResourcePath = "Localization/Resources/en.lproj/Localizable.stringsdict"

    static let StringLocalizableKeyResourcePath = "Localization/StringLocalizableKey.swift"

    static let localizedPackages = [
        "Integration",
        "Interface",
        "Localization",
        "Scenarios",
    ]

}
