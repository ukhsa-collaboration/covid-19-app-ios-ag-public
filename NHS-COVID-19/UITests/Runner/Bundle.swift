//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Bundle {
    
    func localizedBundle(for language: String) -> Bundle? {
        url(forResource: language, withExtension: "lproj").flatMap {
            Bundle(url: $0)
        }
    }
    
}
