//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum Feature: CaseIterable {
    
    /// Shows the new 'no symptoms' screen with more information if someone picks none of the
    /// symptoms in the symptoms questionnaire.
    case newNoSymptomsScreen
    
    /// Puts a button on the home screen that allows people to see the local COVID statistics
    /// for their area and for the whole country.
    case localStatistics
    
    /// Allows people to check in to venues by scanning QR codes.
    /// Does NOT stop people from seeing the venues they've previously checked in to, or receiving
    /// risky venue alerts for those.
    case venueCheckIn
    
    // Shows contact cases in England a questionnaire to determine if they need to isolate or not.
    // This is not changable in the scenarios app and is solely here to allow us to keep test coverage of the England opt out flow.
    case englandOptOutFlow
    
    public static let productionEnabledFeatures: [Feature] = []
}
