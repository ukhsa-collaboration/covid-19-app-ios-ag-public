//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum Feature: CaseIterable {
    
    /// Allows people to tell the app they have had a negative test result from a
    /// daily contact testing programme. This will release them from self-isolation
    /// so that exposure notifications continue to work, in case they test
    /// positive or come into contact with COVID again.
    case dailyContactTesting
    
    /// Shows information about daily contact testing on the screen people see when
    /// they get notified of a potential exposure to COVID-19.
    /// - SeeAlso: `dailyContactTesting`
    case offerDCTOnExposureNotification
    
    public static let productionEnabledFeatures: [Feature] = []
}
