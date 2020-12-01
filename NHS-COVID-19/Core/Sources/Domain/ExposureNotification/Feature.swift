//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum Feature: CaseIterable {
    case localAuthority
    
    public static let productionEnabledFeatures: [Feature] = [.localAuthority]
}
