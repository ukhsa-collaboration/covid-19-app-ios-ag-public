//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum Feature: CaseIterable {
    
    /// Shows the new 'no symptoms' screen with more information if someone picks none of the
    /// symptoms in the symptoms questionnaire.
    case newNoSymptomsScreen
    
    /// Enable user to use the app with bluetooth off.
    case bluetoothOff
    
    public static let productionEnabledFeatures: [Feature] = []
}
