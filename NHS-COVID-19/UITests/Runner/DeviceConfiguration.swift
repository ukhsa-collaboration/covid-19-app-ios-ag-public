//
// Copyright © 2020 NHSX. All rights reserved.
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
        Set(orientationAndStyle + contentSizes + languages)
    }()
    
    static let testConfigurationLanguages: Set<DeviceConfiguration> = {
        Set(languages)
    }()
    
    private static var orientationAndStyle: [DeviceConfiguration] {
        
        let orientations: [UIDeviceOrientation] = [.portrait, .landscapeLeft]
        
        let interfaceStyles: [InterfaceStyle] = [.dark, .light]
        
        return orientations.flatMap { orientation in
            interfaceStyles.map { interfaceStyle in
                DeviceConfiguration(
                    language: "en",
                    orientation: orientation,
                    contentSize: .medium,
                    interfaceStyle: interfaceStyle
                )
            }
        }
    }
    
    private static var contentSizes: [DeviceConfiguration] {
        
        let contentSizes: [UIContentSizeCategory] = [
            .extraSmall,
            .medium,
            .extraLarge,
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
    
}

private class Marker {}
