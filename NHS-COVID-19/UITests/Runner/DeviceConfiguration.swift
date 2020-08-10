//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

enum InterfaceStyle: String {
    case light
    case dark
}

struct DeviceConfiguration {
    var orientation: UIDeviceOrientation
    var contentSize: UIContentSizeCategory
    var interfaceStyle: InterfaceStyle
}

extension DeviceConfiguration {
    init(from device: XCUIDevice) {
        self.init(
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
    
    static let reportConfigurations: [DeviceConfiguration] = {
        
        let contentSizes: [UIContentSizeCategory] = [
            .extraSmall,
            .medium,
            .extraLarge,
            .accessibilityExtraExtraExtraLarge,
        ]
        
        let interfaceStyles: [InterfaceStyle] = [.dark, .light]
        
        return contentSizes.flatMap { contentSize in
            interfaceStyles.map { interfaceStyle in
                DeviceConfiguration(
                    orientation: .portrait,
                    contentSize: contentSize,
                    interfaceStyle: interfaceStyle
                )
            }
        }
    }()
    
    static let reportConfigurationsSparse: [DeviceConfiguration] = {
        styles + contentSizes
    }()
    
    private static var styles: [DeviceConfiguration] {
        
        let interfaceStyles: [InterfaceStyle] = [.dark, .light]
        
        return interfaceStyles.map { interfaceStyle in
            DeviceConfiguration(
                orientation: .portrait,
                contentSize: .medium,
                interfaceStyle: interfaceStyle
            )
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
                orientation: .portrait,
                contentSize: contentSize,
                interfaceStyle: .light
            )
        }
    }
    
}
