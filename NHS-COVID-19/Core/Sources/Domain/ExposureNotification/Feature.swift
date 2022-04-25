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
    
    /// Shows contact cases in England a questionnaire to determine if they need to isolate or not.
    case contactOptOutFlowEngland
    
    /// Shows contact cases in Wales a questionnaire to determine if they need to isolate or not.
    case contactOptOutFlowWales
    
    /// Allows people to find out about the different types of COVID-19 tests and how to get tested.
    /// It's also possible to enter test results in form of a 8 character code received.
    case testingForCOVID19
    
    /// Shows a button leading to the Self-Isolation Hub for people in England who are in isolation.
    case selfIsolationHubEngland
    
    /// Shows a button leading to the Self-Isolation Hub for people in Wales who are in isolation.
    case selfIsolationHubWales
    
    /// Shows a button leading to the Guidance Hub for people in England.
    case guidanceHubEngland
    
    /// Shows a button leading to the Guidance Hub for people in Wales.
    case guidanceHubWales
    
    public static let productionEnabledFeatures: [Feature] = [
        .guidanceHubEngland,
        .guidanceHubWales
    ]
}
