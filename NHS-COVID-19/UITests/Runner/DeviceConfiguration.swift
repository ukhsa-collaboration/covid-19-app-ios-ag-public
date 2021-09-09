//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

enum InterfaceStyle: String {
    case light
    case dark
}

struct DeviceConfiguration: Hashable {
    var language: String
    var orientation: UIDeviceOrientation
    var contentSize: UIContentSizeCategory
    var interfaceStyle: InterfaceStyle
    var showStringLocalizableKeysOnly: Bool = false
}

extension DeviceConfiguration {
    init(from device: XCUIDevice) {
        self.init(
            language: Locale.current.languageCode ?? "en",
            orientation: device.orientation,
            contentSize: .medium,
            interfaceStyle: .light
        )
    }
    
    func configure(_ device: XCUIDevice) {
        device.orientation = orientation
    }
}

extension DeviceConfiguration {
    
    static let reportConfigurations: Set<DeviceConfiguration> = {
        
        let orientations: [UIDeviceOrientation] = [.portrait, .landscapeLeft]
        let languages = Bundle(for: Marker.self).localizations
        
        let contentSizes: [UIContentSizeCategory] = [
            .extraSmall,
            .medium,
            .extraLarge,
            .accessibilityExtraExtraExtraLarge,
        ]
        
        let interfaceStyles: [InterfaceStyle] = [.dark, .light]
        
        return Set(
            languages.flatMap { language in
                orientations.flatMap { orientation in
                    contentSizes.flatMap { contentSize in
                        interfaceStyles.map { interfaceStyle in
                            DeviceConfiguration(
                                language: "en",
                                orientation: orientation,
                                contentSize: contentSize,
                                interfaceStyle: interfaceStyle
                            )
                        }
                    }
                }
            }
        )
    }()
    
    static let reportConfigurationsSparse: Set<DeviceConfiguration> = {
        Set(orientationAndStyleMinimal + contentSizesMinimal + languages + stringLocalizableKeysOnly)
    }()
    
    static let testConfigurationLanguages: Set<DeviceConfiguration> = {
        Set(languages)
    }()
    
    private static var orientationAndStyleMinimal: [DeviceConfiguration] {
        [
            DeviceConfiguration(
                language: "en",
                orientation: .portrait,
                contentSize: .medium,
                interfaceStyle: .light
            ),
            DeviceConfiguration(
                language: "en",
                orientation: .portrait,
                contentSize: .medium,
                interfaceStyle: .dark
            ),
            DeviceConfiguration(
                language: "en",
                orientation: .landscapeLeft,
                contentSize: .medium,
                interfaceStyle: .light
            ),
        ]
    }
    
    private static var contentSizesMinimal: [DeviceConfiguration] {
        
        let contentSizes: [UIContentSizeCategory] = [
            .extraSmall,
            .medium,
            .accessibilityExtraExtraExtraLarge,
        ]
        
        return contentSizes.map { contentSize in
            DeviceConfiguration(
                language: "en",
                orientation: .portrait,
                contentSize: contentSize,
                interfaceStyle: .light
            )
        }
    }
    
    private static var languages: [DeviceConfiguration] {
        
        let languages = Bundle(for: Marker.self).localizations
        
        return languages.map { language in
            DeviceConfiguration(
                language: language,
                orientation: .portrait,
                contentSize: .medium,
                interfaceStyle: .light
            )
        }
    }
    
    private static var stringLocalizableKeysOnly: [DeviceConfiguration] {
        [
            DeviceConfiguration(
                language: "en",
                orientation: .portrait,
                contentSize: .medium,
                interfaceStyle: .light,
                showStringLocalizableKeysOnly: true
            ),
        ]
    }
    
}

private class Marker {}
